// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import UIKit

// MARK: - AutoCodingKeys

extension DeviceMetadata {

    enum CodingKeys: String, CodingKey {
        case appLanguage
        case appScreenWidth
        case appScreenHeight
        case appTimeZoneOffset
        case channel
    }
}

extension NativeAlternativePaymentCaptureRequest {

    enum CodingKeys: String, CodingKey {
        case source
    }
}

extension POAssignCustomerTokenRequest {

    enum CodingKeys: String, CodingKey {
        case source
        case preferredScheme
        case verify
        case invoiceId
        case enableThreeDS2 = "enable_three_d_s_2"
        case thirdPartySdkVersion
        case metadata
    }
}

extension POCardUpdateRequest {

    enum CodingKeys: String, CodingKey {
        case cvc
        case preferredScheme
    }
}

extension POCreateCustomerTokenRequest {

    enum CodingKeys: String, CodingKey {
        case verify
        case returnUrl
        case invoiceReturnUrl
    }
}

extension PODynamicCheckoutPaymentMethod.AlternativePayment {

    enum CodingKeys: String, CodingKey {
        case display
        case flow
        case configuration = "apm"
    }
}

extension PODynamicCheckoutPaymentMethod.ApplePay {

    enum CodingKeys: String, CodingKey {
        case flow
        case configuration = "applepay"
    }
}

extension PODynamicCheckoutPaymentMethod.Card {

    enum CodingKeys: String, CodingKey {
        case display
        case configuration = "card"
    }
}

extension PODynamicCheckoutPaymentMethod.NativeAlternativePayment {

    enum CodingKeys: String, CodingKey {
        case display
        case configuration = "apm"
    }
}

extension POInvoiceAuthorizationRequest {

    enum CodingKeys: String, CodingKey {
        case source
        case saveSource
        case incremental
        case enableThreeDS2 = "enable_three_d_s_2"
        case preferredScheme
        case thirdPartySdkVersion
        case invoiceDetailIds
        case overrideMacBlocking
        case initialSchemeTransactionId
        case autoCaptureAt
        case captureAmount
        case authorizeOnly
        case allowFallbackToSale
        case clientSecret
        case metadata
    }
}

// MARK: - AutoCompletion

extension POCardsService {

    /// Allows to retrieve card issuer information based on IIN.
    /// 
    /// - Parameters:
    ///   - iin: Card issuer identification number. Length should be at least 6 otherwise error is thrown.
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func issuerInformation(
        iin: sending String,
        completion: sending @escaping @isolated(any) (Result<POCardIssuerInformation, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await issuerInformation(iin: iin)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }

    /// Tokenizes a card. You can use the card for a single payment by creating a card token with it. If you want
    /// to use the card for multiple payments then you can use the card token to create a reusable customer token.
    /// Note that once you have used the card token either for a payment or to create a customer token, the card
    /// token becomes invalid and you cannot use it for any further actions.
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func tokenize(
        request: sending POCardTokenizationRequest,
        completion: sending @escaping @isolated(any) (Result<POCard, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await tokenize(request: request)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }

    /// Updates card information.
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func updateCard(
        request: sending POCardUpdateRequest,
        completion: sending @escaping @isolated(any) (Result<POCard, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await updateCard(request: request)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }

    /// Tokenize previously authorized payment.
    @MainActor
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func tokenize(
        request: sending POApplePayPaymentTokenizationRequest,
        completion: sending @escaping @isolated(any) (Result<POCard, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await tokenize(request: request)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }

    /// Authorize given payment request and tokenize it.
    @MainActor
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func tokenize(
        request: sending POApplePayTokenizationRequest,
        delegate: sending POApplePayTokenizationDelegate?,
        completion: sending @escaping @isolated(any) (Result<POCard, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await tokenize(request: request, delegate: delegate)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }

    /// Authorize given payment request and tokenize it.
    @MainActor
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func tokenize(
        request: sending POApplePayTokenizationRequest,
        completion: sending @escaping @isolated(any) (Result<POCard, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await tokenize(request: request)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }
}

extension POCustomerTokensService {

    /// Assigns new source to existing customer token and optionally verifies it.
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func assignCustomerToken(
        request: sending POAssignCustomerTokenRequest,
        threeDSService: sending PO3DS2Service,
        completion: sending @escaping @isolated(any) (Result<POCustomerToken, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await assignCustomerToken(request: request, threeDSService: threeDSService)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }

    /// Creates customer token using given request.
    @_spi(PO)
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func createCustomerToken(
        request: sending POCreateCustomerTokenRequest,
        completion: sending @escaping @isolated(any) (Result<POCustomerToken, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await createCustomerToken(request: request)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }
}

extension POGatewayConfigurationsRepository {

    /// Returns available gateway configurations.
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func all(
        request: sending POAllGatewayConfigurationsRequest,
        completion: sending @escaping @isolated(any) (Result<POAllGatewayConfigurationsResponse, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await all(request: request)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }

    /// Searches configuration with given request.
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func find(
        request: sending POFindGatewayConfigurationRequest,
        completion: sending @escaping @isolated(any) (Result<POGatewayConfiguration, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await find(request: request)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }

    /// Returns available gateway configurations.
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func all(
        completion: sending @escaping @isolated(any) (Result<POAllGatewayConfigurationsResponse, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await all()))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }
}

extension POInvoicesService {

    /// Requests information needed to continue existing payment or start new one.
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func nativeAlternativePaymentMethodTransactionDetails(
        request: sending PONativeAlternativePaymentMethodTransactionDetailsRequest,
        completion: sending @escaping @isolated(any) (Result<PONativeAlternativePaymentMethodTransactionDetails, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await nativeAlternativePaymentMethodTransactionDetails(request: request)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }

    /// Initiates native alternative payment with a given request.
    /// 
    /// Some Native APMs require further information to be collected back from the customer. You can inspect
    /// `nativeApm` in response object to understand if additional data is required.
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func initiatePayment(
        request: sending PONativeAlternativePaymentMethodRequest,
        completion: sending @escaping @isolated(any) (Result<PONativeAlternativePaymentMethodResponse, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await initiatePayment(request: request)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }

    /// Invoice details.
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func invoice(
        request: sending POInvoiceRequest,
        completion: sending @escaping @isolated(any) (Result<POInvoice, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await invoice(request: request)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }

    /// Performs invoice authorization with given request.
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func authorizeInvoice(
        request: sending POInvoiceAuthorizationRequest,
        threeDSService: sending PO3DS2Service,
        completion: sending @escaping @isolated(any) (Result<Void, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await authorizeInvoice(request: request, threeDSService: threeDSService)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }

    /// Captures native alternative payament.
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func captureNativeAlternativePayment(
        request: sending PONativeAlternativePaymentCaptureRequest,
        completion: sending @escaping @isolated(any) (Result<Void, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await captureNativeAlternativePayment(request: request)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }

    /// Creates invoice with given parameters.
    @_spi(PO)
    @available(*, deprecated, message: "Use the async method instead.")
    @discardableResult
    public func createInvoice(
        request: sending POInvoiceCreationRequest,
        completion: sending @escaping @isolated(any) (Result<POInvoice, POFailure>) -> Void
    ) -> POCancellable {
        Task { @MainActor in
            do {
                await completion(.success(try await createInvoice(request: request)))
            } catch {
                await completion(.failure(error as! POFailure))
            }
        }
    }
}
