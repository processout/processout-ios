
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

    static let ApiVersion: String = "v2.10.1"
    private static let ApiUrl: String = "https://api.processout.com"
    internal static let CheckoutUrl: String = "https://checkout.processout.com"
    internal static var ProjectId: String?
    internal static let threeDS2ChallengeSuccess: String = "gway_req_eyJib2R5Ijoie1widHJhbnNTdGF0dXNcIjpcIllcIn0ifQ==";
    internal static let threeDS2ChallengeError: String = "gway_req_eyJib2R5Ijoie1widHJhbnNTdGF0dXNcIjpcIk5cIn0ifQ==";
    internal static let sessionManager = SessionManager()
    internal static let retryPolicy = RetryPolicy()
    
    // Getting the device user agent
    private static let defaultUserAgent = "iOS/" + UIDevice.current.systemVersion

    public static func Setup(projectId: String) {
        ProcessOut.ProjectId = projectId
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
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                
                let tokenizationResult = try JSONDecoder().decode(TokenizationResult.self, from: tokenResponse!)
                if let card = tokenizationResult.card, tokenizationResult.success {
                    completion(card.id, nil)
                } else {
                    guard let message = tokenizationResult.message, let errorType = tokenizationResult.errorType else {
                        completion(nil, ProcessOutException.InternalError)
                        return
                    }
                    completion(nil, ProcessOutException.BadRequest(errorMessage: message, errorCode: errorType))
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
    
    
    public enum GatewayConfigurationsFilter: String {
        case All = ""
        case AlternativePaymentMethods = "alternative-payment-methods"
        case AlternativePaymentMethodWithTokenization = " alternative-payment-methods-with-tokenization"
    }
    
    /// List alternative gateway configurations activated on your account
    ///
    /// - Parameter completion: Completion callback
    public static func fetchGatewayConfigurations(filter: GatewayConfigurationsFilter, completion: @escaping ([GatewayConfiguration]?, ProcessOutException?) -> Void) {
        HttpRequest(route: "/gateway-configurations?filter=" + filter.rawValue + "&expand_merchant_accounts=true", method: .get, parameters: nil) { (gateways
            , e) in
            guard gateways != nil else {
                completion(nil, e)
                return
            }
            
            var result: GatewayConfigurationResult
            do {
                result = try JSONDecoder().decode(GatewayConfigurationResult.self, from: gateways!)
            } catch {
                completion(nil, ProcessOutException.GenericError(error: error))
                return
            }
            
            if let gConfs = result.gatewayConfigurations {
                completion(gConfs, nil)
                return
            }
            completion(nil, ProcessOutException.InternalError)
        }
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
                guard let customerAction = authorizationResult.customerAction else {
                    // No customer action required, payment authorized
                    handler.onSuccess(invoiceId: invoiceId)
                    return
                }
                
                // Initiate the webView component
                let poWebView = CardPaymentWebView(frame: with.view.frame, onResult: {(token) in
                    // Web authentication completed
                    makeCardPayment(invoiceId: invoiceId, token: token, handler: handler, with: with)
                }, onAuthenticationError: {() in
                    // Error while authenticating
                    handler.onError(error: ProcessOutException.BadRequest(errorMessage: "Web authentication failed.", errorCode: ""))
                })
                
                // Initiate the action handler
                let actionHandler = CustomerActionHandler(handler: handler, processOutWebView: poWebView, with: with)
                
                // Start the action handling
                actionHandler.handleCustomerAction(customerAction: customerAction, completion: { (newSource) in
                    // Successful, new source available to continue the flow
                    makeCardPayment(invoiceId: invoiceId, token: newSource, handler: handler, with: with)
                })
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
                
                // Try to decode the auth result
                guard let result = try? JSONDecoder().decode(AuthorizationResult.self, from: data!) else {
                    handler.onError(error: ProcessOutException.InternalError)
                    return
                }
                
                guard let customerAction = result.customerAction else {
                    // Card token verified
                    handler.onSuccess(invoiceId: tokenId)
                    return
                }
                
                // Instantiate the webView
                let poWebView = CardTokenWebView(frame: with.view.frame, onResult: { (token) in
                    // Web authentication completed
                    makeCardToken(source: token, customerId: customerId, tokenId: tokenId, handler: handler, with: with)
                }, onAuthenticationError: {() in
                    // Error while authenticating
                    handler.onError(error: ProcessOutException.BadRequest(errorMessage: "Web authentication failed.", errorCode: ""))
                })
                
                // Instantiate the customer action handler
                let actionHandler = CustomerActionHandler(handler: handler, processOutWebView: poWebView, with: with)
                
                // Start the action handling flow
                actionHandler.handleCustomerAction(customerAction: customerAction, completion: { (newSource) in
                    // Successful, new source available to continue the flow
                    makeCardToken(source: newSource, customerId: customerId, tokenId: tokenId, handler: handler, with: with)
                })
                
            }
        } catch {
            handler.onError(error: ProcessOutException.InternalError)
        }
    }
    
    
    /// Handles returns with deep-links for APM authorizations
    ///
    /// - Parameter url: Deeplink opened
    /// - Returns: A gateway token string if available, nil if not a ProcessOut URL or not available
    @available(*, deprecated, message: "Use handleAPMURLCallback instead.")
    public static func handleURLCallback(url: URL) -> String? {
        guard let host = url.host, host == "processout.return", let parameters = url.queryParameters else {
            return nil
        }
        
        return parameters["token"]
    }
    
    
    /// Parses an intent uri. Either for an APM payment return or after an makeAPMToken call
    ///
    /// - Parameter url: URI from the deep-link app opening
    /// - Returns: nil if the URL is not a ProcessOut return URL, an APMTokenReturn object otherwise
    public static func handleAPMURLCallback(url: URL) -> APMTokenReturn? {
        // Check for the URL host
        guard let host = url.host, host == "processout.return" else {
            return nil
        }
        
        // Retrieve the URL parameters
        guard let params = url.queryParameters else {
            return APMTokenReturn(error: ProcessOutException.InternalError)
        }
        
        // Retrieve the token
        guard let token = params["token"], !token.isEmpty else {
            return APMTokenReturn(error: ProcessOutException.InternalError)
        }
        
        // Retrieve the customer_id and token_id if available
        let customerId = params["customer_id"]
        let tokenId = params["token_id"]
        
        // Check if we're on a tokenization return
        if customerId != nil && !customerId!.isEmpty && tokenId != nil && !tokenId!.isEmpty {
            return APMTokenReturn(token: token, customerId: customerId!, tokenId: tokenId!)
        }
        
        // Simple APM authorization case
        return APMTokenReturn(token: token)
    }
    
    /// Creates a test 3DS2 handler that lets you integrate and test the 3DS2 flow seamlessly. Only use this while using sandbox API keys
    ///
    /// - Parameter viewController: UIViewController (needed to display a 3DS2 challenge popup)
    /// - Returns: Returns a sandbox ready ThreeDS2Handler
    public static func createThreeDSTestHandler(viewController: UIViewController, completion: @escaping (String?, ProcessOutException?) -> Void) -> ThreeDSHandler {
        return ThreeDSTestHandler(controller: viewController, completion: completion)
    }
    
    
    /// Generates an alternative payment method token
    ///
    /// - Parameters:
    ///   - gateway: The alternative payment method configuration
    ///   - customerId: The customer ID
    ///   - tokenId: The token ID generated on your backend with an empty source
    public static func makeAPMToken(gateway: GatewayConfiguration, customerId: String, tokenId: String, additionalData: [String: String] = [:]) {
        // Generate the redirection URL
        let checkout = ProcessOut.ProjectId! + "/" + customerId + "/" + tokenId + "/redirect/" + gateway.id
        let additionalDataString = generateAdditionalDataString(additionalData: additionalData)
        let urlString = ProcessOut.CheckoutUrl + "/" + checkout + additionalDataString
        
        if let url = NSURL(string: urlString) {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    /// Initiate an alternative payment method payment by opening the default browser
    ///
    /// - Parameters:
    ///   - gateway: Gateway to use (previously fetched)
    ///   - invoiceId: Invoice ID generated on your backend
    @available(*, deprecated)
    public static func makeAPMPayment(gateway: GatewayConfiguration, invoiceId: String, additionalData: [String: String] = [:]) {
        // Generate the redirection URL
        let urlString: String = makeAPMPayment(gateway: gateway, invoiceId: invoiceId, additionalData: additionalData)
        
        if let url = NSURL(string: urlString) {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    /// Returns the URL to initiate an alternative payment method payment
    ///
    /// - Parameters:
    ///   - gateway: Gateway to use (previously fetched)
    ///   - invoiceId: Invoice ID generated on your backend
    /// - Returns: Redirect URL that should be displayed in a webview
    public static func makeAPMPayment(gateway: GatewayConfiguration, invoiceId: String, additionalData: [String: String] = [:]) -> String {
        // Generate the redirection URL
        let checkout = ProcessOut.ProjectId! + "/" + invoiceId + "/redirect/" + gateway.id
        let additionalDataString = generateAdditionalDataString(additionalData: additionalData)
        let urlString = ProcessOut.CheckoutUrl + "/" + checkout + additionalDataString
        
        return urlString
    }
    
    
    /// Generates an additionalData query parameter string
    ///
    /// - Parameter additionalData: additionalData to send to the APM
    /// - Returns: a empty string or a string starting with ? followed by the query value
    private static func generateAdditionalDataString(additionalData: [String: String]) -> String {
        // Transform the map into an array of additional_data[key]=value
        let addData = additionalData.map({ (data) -> String in
            let (key, value) = data
            
            // Try to encode value
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            return "additional_data[" + key + "]" + "=" + (encodedValue ?? "")
        })
        
        // The array is empty we return an empty string
        if addData.count == 0 {
            return ""
        }
        
        // Reduce the array into a single string
        return "?" + addData.reduce("", { (result, current) -> String in
            if result.isEmpty {
                return result + current
            }
            
            return result + "&" + current
        })
    }
    
    private static func HttpRequest(route: String, method: HTTPMethod, parameters: Parameters?, completion: @escaping (Data?, ProcessOutException?) -> Void) {
        guard let projectId = ProjectId, let authorizationHeader = Request.authorizationHeader(user: projectId, password: "") else {
            completion(nil, ProcessOutException.MissingProjectId)
            return
        }
        
        if sessionManager.retrier == nil {
            sessionManager.retrier = retryPolicy
        }
        do {
            guard let url = NSURL(string: ApiUrl + route) else {
                completion(nil, ProcessOutException.InternalError)
                return
            }
            
            var request = URLRequest(url: url as URL)
            request.httpMethod = method.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(authorizationHeader.value, forHTTPHeaderField: authorizationHeader.key)
            request.setValue(ProcessOut.defaultUserAgent + " ProcessOut iOS-Bindings/" + ApiVersion, forHTTPHeaderField: "User-Agent")
            request.setValue(UUID().uuidString, forHTTPHeaderField: "Idempotency-Key")
            request.timeoutInterval = 15
            
            if let body = parameters {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            }

            
            sessionManager.request(request as URLRequestConvertible).responseJSON(completionHandler: {(response) -> Void in
                guard let data = response.data else {
                    completion(nil, ProcessOutException.NetworkError)
                    return
                }
                handleNetworkResult(data: data, completion: completion)
            })
        } catch {
            completion(nil, ProcessOutException.InternalError)
        }
    }
    
    private static func handleNetworkResult(data: Data, completion: @escaping (Data?, ProcessOutException?) -> Void) {
        do {
            let result = try JSONDecoder().decode(ApiResponse.self, from: data)
            if result.success {
                completion(data, nil)
                return
            }
            
            if let message = result.message, let errorType = result.errorType {
                completion(nil, ProcessOutException.BadRequest(errorMessage: message, errorCode: errorType))
                return
            }
            
            completion(nil, ProcessOutException.NetworkError)
        } catch {
            completion(nil, ProcessOutException.InternalError)
        }
    }
}

