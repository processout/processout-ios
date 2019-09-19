
import Alamofire
import Foundation
import PassKit
import UIKit
import WebKit

public class ProcessOut {
    
    public struct Contact {
        var Address1: String?
        var Address2: String?
        var City: String?
        var State: String?
        var Zip: String?
        var CountryCode: String?
        
        public init(address1: String?, address2: String?, city: String?, state: String?, zip: String?, countryCode: String?) {
            self.Address1 = address1
            self.Address2 = address2
            self.City = city
            self.State = state
            self.Zip = zip
            self.CountryCode = countryCode
        }
    }
    
    public struct Card {
        var CardNumber: String
        var ExpMonth: Int
        var ExpYear: Int
        var CVC: String?
        var Name: String
        var Contact: Contact?
        
        public init(cardNumber: String, expMonth: Int, expYear: Int, cvc: String?, name: String) {
            self.CardNumber = cardNumber
            self.ExpMonth = expMonth
            self.ExpYear = expYear
            self.CVC = cvc
            self.Name = name
        }
        
        public init(cardNumber: String, expMonth: Int, expYear: Int, cvc: String?, name: String, contact: Contact) {
            self.CardNumber = cardNumber
            self.ExpMonth = expMonth
            self.ExpYear = expYear
            self.CVC = cvc
            self.Name = name
            self.Contact = contact
        }
    }

    private static let ApiUrl: String = "https://api.processout.com"
    internal static let CheckoutUrl: String = "https://checkout.processout.com"
    internal static var ProjectId: String?
    internal static var UrlScheme: String?
    internal static let threeDS2ChallengeSuccess: String = "gway_req_eyJib2R5Ijoie1widHJhbnNTdGF0dXNcIjpcIllcIn0ifQ==";
    internal static let threeDS2ChallengeError: String = "gway_req_eyJib2R5Ijoie1widHJhbnNTdGF0dXNcIjpcIk5cIn0ifQ==";

    public static func Setup(projectId: String) {
        ProcessOut.ProjectId = projectId
    }
    
    public static func Setup(projectId: String, urlScheme: String) {
        ProcessOut.ProjectId = projectId
        ProcessOut.UrlScheme = urlScheme
    }
    
    /// Tokenizes a card with metadata
    ///
    /// - Parameters:
    ///   - card: The card object to be tokenized
    ///   - metadata: Optional metadata to apply to the card tokenization
    ///   - completion: Completion callback
    public static func Tokenize(card: Card, metadata: [String: Any]?, completion: @escaping (String?, ProcessOutException?) -> Void) {
        var parameters: [String: Any] = [:]
        if let metadata = metadata {
            parameters["metadata"] = metadata
        }
        parameters["name"] = card.Name
        parameters["number"] = card.CardNumber
        parameters["exp_month"] = card.ExpMonth
        parameters["exp_year"] = card.ExpYear
        
        if let contact = card.Contact {
            let contactParameters = [
                "address1": contact.Address1,
                "address2": contact.Address2,
                "city": contact.City,
                "state": contact.State,
                "zip": contact.Zip,
                "country_code": contact.CountryCode
            ]
            parameters["contact"] = contactParameters
            
        }
    
        if let cvc = card.CVC {
            parameters["cvc2"] = cvc
        }
      
        HttpRequest(route: "/cards", method: .post, parameters: parameters) { (tokenResponse, error) in
            do {
                if tokenResponse != nil {
                    let tokenizationResult = try JSONDecoder().decode(TokenizationResult.self, from: tokenResponse!)
                    if let card = tokenizationResult.card, tokenizationResult.success {
                        completion(card.id, nil)
                    } else {
                        if let message = tokenizationResult.message, let errorType = tokenizationResult.errorType {
                            completion(nil, ProcessOutException.BadRequest(errorMessage: message, errorCode: errorType))
                        } else {
                            completion(nil, ProcessOutException.InternalError)
                        }
                    }
                }
            } catch {
                completion(nil, ProcessOutException.InternalError)
            }
        }
    }
    
    
    /// ApplePay tokenization
    ///
    /// - Parameters:
    ///   - payment: PKPayment object to be tokenize
    ///   - metadata: Optional metadata
    ///   - completion: Completion callback
    public static func Tokenize(payment: PKPayment, metadata: [String: Any]?, completion: @escaping (String?, ProcessOutException?) -> Void) {
        return Tokenize(payment: payment, metadata: metadata, contact: nil, completion: completion)
    }
    
    
    /// ApplePay tokenization with contact information
    ///
    /// - Parameters:
    ///   - payment: PKPayment object to be tokenize
    ///   - metadata: Optional metadata
    ///   - contact: Customer contact information
    ///   - completion: Completion callback
    public static func Tokenize(payment: PKPayment, metadata: [String: Any]?, contact: Contact?, completion: @escaping (String?, ProcessOutException?) -> Void) {
        
        var parameters: [String: Any] = [:]
        if let metadata = metadata {
            parameters["metadata"] = metadata
        }

        do {
            // Serializing the paymentdata object
            let paymentDataJson: [String: AnyObject]? = try JSONSerialization.jsonObject(with: payment.token.paymentData, options: []) as? [String: AnyObject]
            
            var applepayResponse: [String: Any] = [:]
            var token: [String: Any] = [:]
            
            
            if #available(iOS 9.0, *) {
                // Retrieving additional information
                var paymentMethodType: String
                switch payment.token.paymentMethod.type {
                case .debit:
                    paymentMethodType = "debit"
                    break
                case .credit:
                    paymentMethodType = "credit"
                    break
                case .prepaid:
                    paymentMethodType = "prepaid"
                    break
                case .store:
                    paymentMethodType = "store"
                    break
                default:
                    paymentMethodType = "unknown"
                    break
                }
                let paymentMethod: [String: Any] = [
                    "displayName":payment.token.paymentMethod.displayName ?? "",
                    "network": payment.token.paymentMethod.network?.rawValue ?? "",
                    "type": paymentMethodType
                ]
                token["paymentMethod"] = paymentMethod
            } else {
                // PaymentMethod isn't available we just skip this field
            }
            
            token["transactionIdentifier"] = payment.token.transactionIdentifier
            token["paymentData"] = paymentDataJson
            applepayResponse["token"] = token
            parameters["applepay_response"] = applepayResponse
            parameters["token_type"] = "applepay"
            
            if contact != nil {
                let contactParameters = [
                    "address1": contact?.Address1,
                    "address2": contact?.Address2,
                    "city": contact?.City,
                    "state": contact?.State,
                    "zip": contact?.Zip,
                    "country_code": contact?.CountryCode
                ]
                parameters["contact"] = contactParameters
            }
            
            HttpRequest(route: "/cards", method: .post, parameters: parameters) { (tokenResponse, error) in
                do {
                    if tokenResponse != nil {
                        let tokenizationResult = try JSONDecoder().decode(TokenizationResult.self, from: tokenResponse!)
                        if let card = tokenizationResult.card, tokenizationResult.success {
                            completion(card.id, nil)
                        } else {
                            if let message = tokenizationResult.message, let errorType = tokenizationResult.errorType {
                                completion(nil, ProcessOutException.BadRequest(errorMessage: message, errorCode: errorType))
                            } else {
                                completion(nil, ProcessOutException.InternalError)
                            }
                        }
                    }
                } catch {
                    completion(nil, ProcessOutException.InternalError)
                }
            }
        } catch {
            // Could not parse the PKPaymentData object
            completion(nil, ProcessOutException.GenericError(error: error))
            
        }
    }
    
    
    /// Update a previously stored card CVC
    ///
    /// - Parameters:
    ///   - cardId: Card ID to be updated
    ///   - newCvc: New CVC
    ///   - completion: Completion callback
    public static func UpdateCvc(cardId: String, newCvc: String, completion: @escaping (ProcessOutException?) -> Void) {
        let parameters: [String: Any] = [
            "cvc": newCvc
        ]
        
        HttpRequest(route: "/cards/" + cardId, method: .put, parameters: parameters) { (response, error) in
            completion(error)
        }
    }
    
    
    /// List alternative gateway configurations activated on your account
    ///
    /// - Parameter completion: Completion callback
    public static func listAlternativeMethods(completion: @escaping ([AlternativeGateway]?, ProcessOutException?) -> Void) {
        HttpRequest(route: "/gateway-configurations?filter=alternative-payment-methods&expand_merchant_accounts=true", method: .get, parameters: [:]) { (gateways
            , e) in
            if gateways != nil {
                do {
                    let result = try JSONDecoder().decode(AlternativeGatewaysResult.self, from: gateways!)
                    if let gConfs = result.gatewayConfigurations {
                        completion(gConfs, nil)
                    } else {
                        completion(nil, ProcessOutException.InternalError)
                    }
                } catch {
                    completion(nil, ProcessOutException.GenericError(error: error))
                }
            } else {
                completion(nil, e)
            }
        }
    }
    
    /// Checks if an URL matches the ProcessOut return url schemes and returns an object containing chargeable information
    ///
    /// - Parameter url: URL catched by the app delegate
    /// - Returns: a WebViewReturn object containing its type and chargeable value (token or invoiceId)
    public static func handleURLCallback(url: URL) -> WebViewReturn? {
        func getQueryStringParameter(url: String, param: String) -> String? {
            guard let url = URLComponents(string: url) else { return nil }
            return url.queryItems?.first(where: { $0.name == param })?.value
        }
        
        if let host = url.host, host != "processout.return" {
            return nil
        }
        
        let token = getQueryStringParameter(url: url.absoluteString, param: "token")
        let threeDSStatus = getQueryStringParameter(url: url.absoluteString, param: "three_d_s_status")
        let invoice = getQueryStringParameter(url: url.absoluteString, param: "invoice_id")
        
        if let tokenValue = token, !tokenValue.isEmpty, threeDSStatus == nil || threeDSStatus!.isEmpty {
            return WebViewReturn(success: true, type: .APMAuthorization, value: tokenValue)
        }
        if let tokenValue = token, !tokenValue.isEmpty, let invoiceValue = invoice, !invoiceValue.isEmpty {
            return WebViewReturn(success: true, type: .ThreeDSFallbackVerification, value: tokenValue, invoiceId: invoiceValue)
        }
        if let threeDSStatusValue = threeDSStatus, !threeDSStatusValue.isEmpty, let invoiceValue = invoice, !invoiceValue.isEmpty {
            switch threeDSStatusValue {
            case "success":
                return WebViewReturn(success: true, type: .ThreeDSResult, value: invoiceValue)
            default:
                return WebViewReturn(success: false, type: .ThreeDSResult, value: "")
            }
        }
        
        return nil
    }
    
    /// Initiate a payment authorization from a previously generated invoice and card token
    ///
    /// - Parameters:
    ///   - invoiceId: Invoice generated on your backend
    ///   - token: Card token to be used for the charge
    ///   - handler: Custom 3DS2 handler (please refer to our documentation for this)
    ///   - with: UIViewController to display webviews and perform fingerprinting
    public static func makeCardPayment(invoiceId: String, token: String, handler: ThreeDSHandler, with: UIViewController) {
        let authRequest = AuthorizationRequest(source: token)
        guard let body = try? JSONEncoder().encode(authRequest) else {
            handler.onError(error: ProcessOutException.InternalError)
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: body, options: []) as! [String : Any]
            HttpRequest(route: "/invoices/" + invoiceId + "/authorize", method: .post, parameters: json, completion: {(data, error) -> Void in
                guard data != nil else {
                    handler.onError(error: error!)
                    return
                }
                
                guard let authorizationResult = try? JSONDecoder().decode(AuthorizationResult.self, from: data!) else {
                    handler.onError(error: ProcessOutException.InternalError)
                    return
                }
                handleAuthorizationRequest(invoiceId: invoiceId, source: token, handler: handler, result: authorizationResult, with: with)
            })
        } catch {
            handler.onError(error: ProcessOutException.GenericError(error: error))
        }
    }
    
    /// Create a customer token from a card ID
    ///
    /// - Parameters:
    ///   - cardId: Card ID used for the customer token
    ///   - customerId: Customer ID created in backend
    ///   - tokenId: Token ID created in backend
    ///   - handler: 3DS2 handler
    ///   - with: UIViewController to display webviews and perform fingerprinting
    public static func makeCardToken(source: String, customerId: String, tokenId: String, handler: ThreeDSHandler, with: UIViewController) {
        let tokenRequest = TokenRequest(source: source)
        guard let body = try? JSONEncoder().encode(tokenRequest) else {
            handler.onError(error: ProcessOutException.InternalError)
            return
        }
        do {
            let json = try JSONSerialization.jsonObject(with: body, options: []) as! [String: Any]
            HttpRequest(route: "/customers/" + customerId + "/tokens/" + tokenId, method: .put, parameters: json) { (data, error) in
                guard error == nil, data != nil else {
                    handler.onError(error: error!)
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(AuthorizationResult.self, from: data!)
                    if let customerAction = result.customerAction {
                        let actionHandler = CustomerActionHandler(handler: handler, with: with)
                        actionHandler.handleCustomerAction(customerAction: customerAction, completion: { (newSource) in
                            makeCardToken(source: newSource, customerId: customerId, tokenId: tokenId, handler: handler, with: with)
                        })
                    } else {
                        handler.onSuccess(invoiceId: tokenId)
                    }
                } catch {
                    handler.onError(error: ProcessOutException.InternalError)
                }
            }
        } catch {
            handler.onError(error: ProcessOutException.InternalError)
        }
    }
    
    /// Creates a test 3DS2 handler that lets you integrate and test the 3DS2 flow seamlessly. Only use this while using sandbox API keys
    ///
    /// - Parameter viewController: UIViewController (needed to display a 3DS2 challenge popup)
    /// - Returns: Returns a sandbox ready ThreeDS2Handler
    public static func createThreeDSTestHandler(viewController: UIViewController, completion: @escaping (String?, ProcessOutException?) -> Void) -> ThreeDSHandler {
        return ThreeDSTestHandler(controller: viewController, completion: completion)
    }
    
    private static func handleAuthorizationRequest(invoiceId: String, source: String, handler: ThreeDSHandler, result: AuthorizationResult, with: UIViewController) {
        if let customerAction = result.customerAction {
            let actionHandler = CustomerActionHandler(handler: handler, with: with)
            actionHandler.handleCustomerAction(customerAction: customerAction) { (newSource) in
                makeCardPayment(invoiceId: invoiceId, token: newSource, handler: handler, with: with)
            }
        } else {
            handler.onSuccess(invoiceId: invoiceId)
        }
    }

    public static func continueThreeDSVerification(invoiceId: String, token: String, completion: @escaping (String?, ProcessOutException?) -> Void) {
        let authRequest = AuthorizationRequest(source: token)
        if let body = try? JSONEncoder().encode(authRequest) {
            do {
                let json = try JSONSerialization.jsonObject(with: body, options: []) as! [String : Any]
                HttpRequest(route: "/invoices/" + invoiceId + "/authorize", method: .post, parameters: json, completion: {(data, error) -> Void in
                    if data != nil {
                        completion(invoiceId, nil)
                    } else {
                        completion(nil, error!)
                    }
                })
            } catch {
                completion(nil, ProcessOutException.GenericError(error: error))
            }
        } else {
            completion(nil, ProcessOutException.InternalError)
        }
    }
    
    private static func HttpRequest(route: String, method: HTTPMethod, parameters: Parameters, completion: @escaping (Data?, ProcessOutException?) -> Void) {
        guard let projectId = ProjectId, let authorizationHeader = Request.authorizationHeader(user: projectId, password: "") else {
            completion(nil, ProcessOutException.MissingProjectId)
            return
        }
      
        var headers: HTTPHeaders = [:]
      
        headers[authorizationHeader.key] = authorizationHeader.value
        Alamofire.request(ApiUrl + route, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {(response) -> Void in
            do {
                if let data = response.data {
                    let result = try JSONDecoder().decode(ApiResponse.self, from: response.data!)
                    if result.success {
                       completion(data, nil)
                    } else {
                        if let message = result.message, let errorType = result.errorType {
                            completion(nil, ProcessOutException.BadRequest(errorMessage: message, errorCode: errorType))
                        } else {
                            completion(nil, ProcessOutException.NetworkError)
                        }
                    }
                } else {
                    completion(nil, ProcessOutException.NetworkError)
                }
            } catch {
                completion(nil, ProcessOutException.InternalError)
            }
        })
    }
}

