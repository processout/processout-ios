// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import UIKit

// MARK: - AutoCodingKeys

extension NativeAlternativePaymentCaptureRequest {

    enum CodingKeys: String, CodingKey {
        case source
    }
}

extension POAssignCustomerTokenRequest {

    enum CodingKeys: String, CodingKey {
        case customerId
        case tokenId
        case source
        case preferredScheme
        case verify
        case invoiceId
        case enableThreeDS2 = "enable_three_d_s_2"
        case thirdPartySdkVersion
        case metadata
        case localeIdentifier
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
        case invoiceId
        case source
        case saveSource
        case incremental
        case enableThreeDS2 = "enable_three_d_s_2"
        case preferredScheme
        case thirdPartySdkVersion
        case overrideMacBlocking
        case initialSchemeTransactionId
        case autoCaptureAt
        case captureAmount
        case allowFallbackToSale
        case clientSecret
        case metadata
        case webAuthenticationCallback
        case prefersEphemeralWebAuthenticationSession
    }
}

// MARK: - AutoCompletion


extension POCardsService {

    /// Allows to retrieve card issuer information based on IIN.
    /// 
    /// - Parameters:
    ///   - iin: Card issuer identification number. Length should be at least 6 otherwise error is thrown.
    @available(*, deprecated, message: "Use the async method instead.")
    @preconcurrency
    @discardableResult
    public func issuerInformation(
        iin: String,
        completion: sending @escaping @isolated(any) (Result<POCardIssuerInformation, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await issuerInformation(iin: iin)
        }
    }

    /// Tokenizes a card. You can use the card for a single payment by creating a card token with it. If you want
    /// to use the card for multiple payments then you can use the card token to create a reusable customer token.
    /// Note that once you have used the card token either for a payment or to create a customer token, the card
    /// token becomes invalid and you cannot use it for any further actions.
    @available(*, deprecated, message: "Use the async method instead.")
    @preconcurrency
    @discardableResult
    public func tokenize(
        request: POCardTokenizationRequest,
        completion: sending @escaping @isolated(any) (Result<POCard, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await tokenize(request: request)
        }
    }

    /// Updates card information.
    @available(*, deprecated, message: "Use the async method instead.")
    @preconcurrency
    @discardableResult
    public func updateCard(
        request: POCardUpdateRequest,
        completion: sending @escaping @isolated(any) (Result<POCard, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await updateCard(request: request)
        }
    }

    /// Tokenize previously authorized payment.
    @available(*, deprecated, message: "Use the async method instead.")
    @MainActor
    @preconcurrency
    @discardableResult
    public func tokenize(
        request: POApplePayPaymentTokenizationRequest,
        completion: sending @escaping @isolated(any) (Result<POCard, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await tokenize(request: request)
        }
    }

    /// Authorize given payment request and tokenize it.
    @available(*, deprecated, message: "Use the async method instead.")
    @MainActor
    @preconcurrency
    @discardableResult
    public func tokenize(
        request: POApplePayTokenizationRequest,
        delegate: POApplePayTokenizationDelegate?,
        completion: sending @escaping @isolated(any) (Result<POCard, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await tokenize(request: request, delegate: delegate)
        }
    }

    /// Authorize given payment request and tokenize it.
    @available(*, deprecated, message: "Use the async method instead.")
    @MainActor
    @preconcurrency
    @discardableResult
    public func tokenize(
        request: POApplePayTokenizationRequest,
        completion: sending @escaping @isolated(any) (Result<POCard, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await tokenize(request: request)
        }
    }
}

extension POCustomerTokensService {

    /// Creates customer token using given request.
    @available(*, deprecated, message: "Use the async method instead.")
    @_spi(PO)
    @preconcurrency
    @discardableResult
    public func createCustomerToken(
        request: POCreateCustomerTokenRequest,
        completion: sending @escaping @isolated(any) (Result<POCustomerToken, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await createCustomerToken(request: request)
        }
    }

    /// Assigns new source to existing customer token and optionally verifies it.
    @available(*, deprecated, message: "Use the async method instead.")
    @preconcurrency
    @discardableResult
    public func assignCustomerToken(
        request: POAssignCustomerTokenRequest,
        threeDSService: PO3DS2Service,
        completion: sending @escaping @isolated(any) (Result<POCustomerToken, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await assignCustomerToken(request: request, threeDSService: threeDSService)
        }
    }

    /// Deletes customer token.
    @available(*, deprecated, message: "Use the async method instead.")
    @preconcurrency
    @discardableResult
    public func deleteCustomerToken(
        request: PODeleteCustomerTokenRequest,
        completion: sending @escaping @isolated(any) (Result<Void, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await deleteCustomerToken(request: request)
        }
    }
}

extension POGatewayConfigurationsRepository {

    /// Returns available gateway configurations.
    @available(*, deprecated, message: "Use the async method instead.")
    @preconcurrency
    @discardableResult
    public func all(
        request: POAllGatewayConfigurationsRequest,
        completion: sending @escaping @isolated(any) (Result<POAllGatewayConfigurationsResponse, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await all(request: request)
        }
    }

    /// Searches configuration with given request.
    @available(*, deprecated, message: "Use the async method instead.")
    @preconcurrency
    @discardableResult
    public func find(
        request: POFindGatewayConfigurationRequest,
        completion: sending @escaping @isolated(any) (Result<POGatewayConfiguration, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await find(request: request)
        }
    }

    /// Returns available gateway configurations.
    @available(*, deprecated, message: "Use the async method instead.")
    @preconcurrency
    @discardableResult
    public func all(
        completion: sending @escaping @isolated(any) (Result<POAllGatewayConfigurationsResponse, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await all()
        }
    }
}

extension POInvoicesService {

    /// Creates invoice with given parameters.
    @available(*, deprecated, message: "Use the async method instead.")
    @_spi(PO)
    @preconcurrency
    @discardableResult
    public func createInvoice(
        request: POInvoiceCreationRequest,
        completion: sending @escaping @isolated(any) (Result<POInvoice, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await createInvoice(request: request)
        }
    }

    /// Invoice details.
    @available(*, deprecated, message: "Use the async method instead.")
    @preconcurrency
    @discardableResult
    public func invoice(
        request: POInvoiceRequest,
        completion: sending @escaping @isolated(any) (Result<POInvoice, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await invoice(request: request)
        }
    }

    /// Performs invoice authorization with given request.
    @available(*, deprecated, message: "Use the async method instead.")
    @preconcurrency
    @discardableResult
    public func authorizeInvoice(
        request: POInvoiceAuthorizationRequest,
        threeDSService: PO3DS2Service,
        completion: sending @escaping @isolated(any) (Result<Void, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await authorizeInvoice(request: request, threeDSService: threeDSService)
        }
    }

    /// Requests information needed to continue existing payment or start new one.
    @available(*, deprecated, message: "Use the async method instead.")
    @preconcurrency
    @discardableResult
    public func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest,
        completion: sending @escaping @isolated(any) (Result<PONativeAlternativePaymentMethodTransactionDetails, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await nativeAlternativePaymentMethodTransactionDetails(request: request)
        }
    }

    /// Initiates native alternative payment with a given request.
    /// 
    /// Some Native APMs require further information to be collected back from the customer. You can inspect
    /// `nativeApm` in response object to understand if additional data is required.
    @available(*, deprecated, message: "Use the async method instead.")
    @preconcurrency
    @discardableResult
    public func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest,
        completion: sending @escaping @isolated(any) (Result<PONativeAlternativePaymentMethodResponse, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await initiatePayment(request: request)
        }
    }

    /// Captures native alternative payament.
    @available(*, deprecated, message: "Use the async method instead.")
    @preconcurrency
    @discardableResult
    public func captureNativeAlternativePayment(
        request: PONativeAlternativePaymentCaptureRequest,
        completion: sending @escaping @isolated(any) (Result<Void, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await captureNativeAlternativePayment(request: request)
        }
    }
}

/// Invokes given completion with a result of async operation.
private func invoke<T>(
    completion: sending @escaping @isolated(any) (Result<T, POFailure>) -> Void,
    withResultOf operation: @escaping @MainActor () async throws -> T
) -> POCancellable {
    Task { @MainActor in
        do {
            let returnValue = try await operation()
            await completion(.success(returnValue))
        } catch let failure as POFailure {
            await completion(.failure(failure))
        } catch {
            let failure = POFailure(message: "Something went wrong.", code: .Mobile.internal, underlyingError: error)
            await completion(.failure(failure))
        }
    }
}

