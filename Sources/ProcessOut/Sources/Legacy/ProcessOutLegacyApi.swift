
import Foundation
import PassKit
import UIKit
import WebKit

@available(*, deprecated, message: "Use ProcessOut instead.")
public final class ProcessOutLegacyApi {

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

    @available(*, deprecated, message: "Use POPaginationOptions instead.")
    public struct PaginationOptions {
        var StartAfter: String?
        var EndBefore: String?
        var Limit: Int?
        var Order: String?
        
        public init(StartAfter: String? = nil, EndBefore: String? = nil, Limit: Int? = nil, Order: String? = nil) {
            self.StartAfter = StartAfter
            self.EndBefore = EndBefore
            self.Limit = Limit
            self.Order = Order
        }
    }

    /// Tokenizes a card with metadata
    ///
    /// - Parameters:
    ///   - card: The card object to be tokenized
    ///   - metadata: Optional metadata to apply to the card tokenization
    ///   - completion: Completion callback
    public static func Tokenize(card: Card, metadata: [String: Any]?, completion: @escaping (String?, ProcessOutException?) -> Void) {
        completion(nil, .InternalError)
    }
    
    /// ApplePay tokenization
    ///
    /// - Parameters:
    ///   - payment: PKPayment object to be tokenize
    ///   - metadata: Optional metadata
    ///   - completion: Completion callback
    public static func Tokenize(payment: PKPayment, metadata: [String: Any]?, completion: @escaping (String?, ProcessOutException?) -> Void) {
        completion(nil, .InternalError)
    }

    /// ApplePay tokenization with contact information
    ///
    /// - Parameters:
    ///   - payment: PKPayment object to be tokenize
    ///   - metadata: Optional metadata
    ///   - contact: Customer contact information
    ///   - completion: Completion callback
    public static func Tokenize(payment: PKPayment, metadata: [String: Any]?, contact: Contact?, completion: @escaping (String?, ProcessOutException?) -> Void) {
        completion(nil, .InternalError)
    }

    /// Update a previously stored card CVC
    ///
    /// - Parameters:
    ///   - cardId: Card ID to be updated
    ///   - newCvc: New CVC
    ///   - completion: Completion callback
    public static func UpdateCvc(cardId: String, newCvc: String, completion: @escaping (ProcessOutException?) -> Void) {
        completion(.InternalError)
    }

    @available(*, deprecated, message: "Use POAllGatewayConfigurationsRequest.Filter instead.")
    public enum GatewayConfigurationsFilter: String {
        case All = ""
        case AlternativePaymentMethods = "alternative-payment-methods"
        case AlternativePaymentMethodWithTokenization = " alternative-payment-methods-with-tokenization"
    }
    
    /// List alternative gateway configurations activated on your account
    ///
    /// - Parameters:
    ///   - completion: Completion callback
    ///   - paginationOptions: Pagination options to use
    @available(*, deprecated, message: "Use ProcessOut.shared.gatewayConfigurations.all instead.")
    public static func fetchGatewayConfigurations(filter: GatewayConfigurationsFilter, completion: @escaping ([GatewayConfiguration]?, ProcessOutException?) -> Void, paginationOptions: PaginationOptions? = nil) {
        completion(nil, .InternalError)
    }

    /// Initiate a payment authorization from a previously generated invoice and card token
    ///
    /// - Parameters:
    ///   - invoiceId: Invoice generated on your backend
    ///   - token: Card token to be used for the charge
    ///   - thirdPartySDKVersion: Version of the 3rd party SDK being used for the calls. Can be blank if unused
    ///   - handler: Custom 3DS2 handler (please refer to our documentation for this)
    ///   - with: UIViewController to display webviews and perform fingerprinting
    public static func makeCardPayment(invoiceId: String, token: String, thirdPartySDKVersion: String, handler: ThreeDSHandler, with: UIViewController) {
        handler.onError(error: .InternalError)
    }
    
    /// Initiate a payment authorization from a previously generated invoice and card token
    ///
    /// - Parameters:
    ///   - invoiceId: Invoice generated on your backend
    ///   - token: Card token to be used for the charge
    ///   - handler: Custom 3DS2 handler (please refer to our documentation for this)
    ///   - with: UIViewController to display webviews and perform fingerprinting
    public static func makeCardPayment(invoiceId: String, token: String, handler: ThreeDSHandler, with: UIViewController) {
        handler.onError(error: .InternalError)
    }

    /// Initiate a payment authorization from a previously generated invoice and card token
    ///
    /// - Parameters:
    ///   - request: contains all the necessary fields to initiate an authorisation request.
    ///   - handler: Custom 3DS2 handler (please refer to our documentation for this)
    ///   - with: UIViewController to display webviews and perform fingerprinting
    public static func makeCardPayment(AuthorizationRequest request: AuthorizationRequest, handler: ThreeDSHandler, with: UIViewController) {
        handler.onError(error: .InternalError)
    }
    
    /// Initiate an incremental payment authorization from a previously generated invoice and card token
    ///
    /// - Parameters:
    ///   - invoiceId: Invoice generated on your backend
    ///   - token: Card token to be used for the charge
    ///   - handler: Custom 3DS2 handler (please refer to our documentation for this)
    ///   - with: UIViewController to display webviews and perform fingerprinting
    public static func makeIncrementalAuthorizationPayment(invoiceId: String, token: String,  handler: ThreeDSHandler, with: UIViewController) {
        handler.onError(error: .InternalError)
    }

    /// Initiate an incremental payment authorization from a previously generated invoice and card token
    ///
    /// - Parameters:
    ///   - invoiceId: Invoice generated on your backend
    ///   - token: Card token to be used for the charge
    ///   - thirdPartySDKVersion: Version of the 3rd party SDK being used for the calls. Can be blank if unused
    ///   - handler: Custom 3DS2 handler (please refer to our documentation for this)
    ///   - with: UIViewController to display webviews and perform fingerprinting
    public static func makeIncrementalAuthorizationPayment(invoiceId: String, token: String, thirdPartySDKVersion: String, handler: ThreeDSHandler, with: UIViewController) {
        handler.onError(error: .InternalError)
    }

    /// Initiate an incremental payment authorization from a previously generated invoice and card token
    ///
    /// - Parameters:
    ///   - request: contains all the necessary fields to initiate an authorisation request.
    ///   - handler: Custom 3DS2 handler (please refer to our documentation for this)
    ///   - with: UIViewController to display webviews and perform fingerprinting
    public static func makeIncrementalAuthorizationPayment(AuthorizationRequest request: AuthorizationRequest, handler: ThreeDSHandler, with: UIViewController) {
        handler.onError(error: .InternalError)
    }
    
    /// Increments the authorization of an applicable invoice by a given amount
    ///
    /// - Parameters:
    ///   - invoiceId: Invoice generated on your backend
    ///   - amount: The amount by which the authorization should be incremented
    ///   - handler: Custom 3DS2 handler (please refer to our documentation for this)
    public static func incrementAuthorizationAmount(invoiceId: String, amount: Int, handler: ThreeDSHandler) {
        handler.onError(error: .InternalError)
    }
    
    /// Create a customer token from a card ID
    ///
    /// - Parameters:
    ///   - customerId: Customer ID created in backend
    ///   - tokenId: Token ID created in backend
    ///   - handler: 3DS2 handler
    ///   - with: UIViewController to display webviews and perform fingerprinting
    public static func makeCardToken(source: String, customerId: String, tokenId: String, handler: ThreeDSHandler, with: UIViewController) {
        handler.onError(error: .InternalError)
    }
    
    /// Create a customer token from a card ID
    ///
    /// - Parameters:
    ///   - customerId: Customer ID created in backend
    ///   - tokenId: Token ID created in backend
    ///   - thirdPartySDKVersion: Version of the 3rd party SDK being used for the calls. Can be blank if unused
    ///   - handler: 3DS2 handler
    ///   - with: UIViewController to display webviews and perform fingerprinting
    public static func makeCardToken(source: String, customerId: String, tokenId: String, thirdPartySDKVersion: String, handler: ThreeDSHandler, with: UIViewController) {
        handler.onError(error: .InternalError)
    }

    /// Create a customer token from a card ID
    ///
    /// - Parameters:
    ///   - request: contains all the fields necessary for the token request
    ///   - handler: 3DS2 handler
    ///   - with: UIViewController to display webviews and perform fingerprinting
    public static func makeCardToken(TokenRequest request: TokenRequest, handler: ThreeDSHandler, with: UIViewController) {
        handler.onError(error: .InternalError)
    }

    /// Creates a test 3DS2 handler that lets you integrate and test the 3DS2 flow seamlessly. Only use this while using sandbox API keys
    ///
    /// - Parameter viewController: UIViewController (needed to display a 3DS2 challenge popup)
    /// - Returns: Returns a sandbox ready ThreeDS2Handler
    @available(*, deprecated)
    public static func createThreeDSTestHandler(viewController: UIViewController, completion: @escaping (String?, ProcessOutException?) -> Void) -> ThreeDSHandler {
        return ThreeDSTestHandler(controller: viewController, completion: completion)
    }

    /// Parses an intent uri. Either for an APM payment return or after an makeAPMToken call
    ///
    /// - Parameter url: URI from the deep-link app opening
    /// - Returns: nil if the URL is not a ProcessOut return URL, an APMTokenReturn object otherwise
    @available(*, deprecated, message: "Use ProcessOut.shared.alternativePaymentMethods.alternativePaymentMethodResponse instead.")
    public static func handleAPMURLCallback(url: URL) -> APMTokenReturn? {
        nil
    }

    /// Generates an alternative payment method token
    ///
    /// - Parameters:
    ///   - gateway: The alternative payment method configuration
    ///   - customerId: The customer ID
    ///   - tokenId: The token ID generated on your backend with an empty source
    @available(*, deprecated, message: "Use POAlternativePaymentMethodViewControllerBuilder to initiate APM payment.")
    public static func makeAPMToken(gateway: GatewayConfiguration, customerId: String, tokenId: String, additionalData: [String: String] = [:]) {
        // Does nothing
    }

    /// Returns the URL to initiate an alternative payment method payment
    ///
    /// - Parameters:
    ///   - gateway: Gateway to use (previously fetched)
    ///   - invoiceId: Invoice ID generated on your backend
    /// - Returns: Redirect URL that should be displayed in a webview
    @available(*, deprecated, message: "Use POAlternativePaymentMethodViewControllerBuilder to initiate APM payment.")
    public static func makeAPMPayment(gateway: GatewayConfiguration, invoiceId: String, additionalData: [String: String] = [:]) -> String {
        ""
    }
}
