
import Alamofire
import Foundation
import PassKit

public class ProcessOut {
    
    public enum ProcessOutException: Error {
        case NetworkError
        case MissingProjectId
        case BadRequest(errorMessage: String, errorCode: String)
        case InternalError
        case GenericError(error: Error)
    }
    
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

    private static var ApiUrl: String = "https://api.processout.com"
    internal static var CheckoutUrl: String = "https://checkout.processout.com"
    internal static var ProjectId: String?
    
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
            if let card = tokenResponse?["card"] as? [String: Any], let token = card["id"] as? String {
                completion(token, nil)
            } else {
                completion(nil, error)
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
                if let card = tokenResponse?["card"] as? [String: Any], let token = card["id"] as? String {
                    completion(token, nil)
                } else {
                    completion(nil, error)
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
    public static func listAlternativeMethods(completion: @escaping ([AlternativeGateway]?, Error?) -> Void) {
        HttpRequest(route: "/gateway-configurations?filter=alternative-payment-methods&expand_merchant_accounts=true", method: .get, parameters: [:]) { (gateways
            , e) in
            if gateways != nil {
                do {
                    if let gConfs = gateways!["gateway_configurations"] {
                        let jsondata = try JSONSerialization.data(withJSONObject: gConfs, options: JSONSerialization.WritingOptions.prettyPrinted)
                        print(jsondata)
                        let altG = try JSONDecoder().decode([AlternativeGateway].self, from: jsondata)
                        completion(altG, nil)
                    } else {
                        completion(nil, ProcessOutException.InternalError)
                    }
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, e)
            }
        }
    }
    
    /// Checks if an URL matches the ProcessOut return url schemes and returns the chargeable gateway token if so
    ///
    /// - Parameter url: URL catched by the app delegate
    /// - Returns: a chargeable gateway token if applicable, nil otherwise
    public static func handleURLCallback(url: URL) -> String? {
        func getQueryStringParameter(url: String, param: String) -> String? {
            guard let url = URLComponents(string: url) else { return nil }
            return url.queryItems?.first(where: { $0.name == param })?.value
        }
        
        if let token = getQueryStringParameter(url: url.absoluteString, param: "token") {
            return token
        }
        return nil
    }
    
    private static func HttpRequest(route: String, method: HTTPMethod, parameters: Parameters, completion: @escaping ([String: Any]?, ProcessOutException?) -> Void) {
        guard let projectId = ProjectId, let authorizationHeader = Request.authorizationHeader(user: projectId, password: "") else {
            completion(nil, ProcessOutException.MissingProjectId)
            return
        }
      
        var headers: HTTPHeaders = [:]
      
        headers[authorizationHeader.key] = authorizationHeader.value
        Alamofire.request(ApiUrl + route, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {(response) -> Void in
            if let data = response.result.value as? [String: Any] {
                if let success = data["success"] as? Bool, success {
                    completion(data, nil)
                } else {
                    if let errorMessage = data["message"] as? String, let errorType = data["error_type"] as? String {
                        completion(nil, ProcessOutException.BadRequest(errorMessage: errorMessage, errorCode: errorType))
                    } else {
                        completion(nil, ProcessOutException.InternalError)
                    }
                }
            } else {
                completion(nil, ProcessOutException.NetworkError)
            }
        })
    }
}

