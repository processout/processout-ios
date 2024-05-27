// Generated using Sourcery 2.2.4 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import UIKit

// MARK: - AutoCodingKeys

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
        case metadata
    }
}

// MARK: - AutoCompletion

extension POCardsService {

    /// Allows to retrieve card issuer information based on IIN.
    /// 
    /// - Parameters:
    ///   - iin: Card issuer identification number. Corresponds to the first 6 or 8 digits of the main card number.
    @discardableResult
    public func issuerInformation(
        iin: String,
        completion: @escaping (Result<POCardIssuerInformation, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await issuerInformation(iin: iin)
        }
    }

    /// Tokenizes a card. You can use the card for a single payment by creating a card token with it. If you want
    /// to use the card for multiple payments then you can use the card token to create a reusable customer token.
    /// Note that once you have used the card token either for a payment or to create a customer token, the card
    /// token becomes invalid and you cannot use it for any further actions.
    @discardableResult
    public func tokenize(
        request: POCardTokenizationRequest,
        completion: @escaping (Result<POCard, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await tokenize(request: request)
        }
    }

    /// Updates card information.
    @discardableResult
    public func updateCard(
        request: POCardUpdateRequest,
        completion: @escaping (Result<POCard, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await updateCard(request: request)
        }
    }

    /// Tokenize a card via ApplePay. You can use the card for a single payment by creating a card token with it.
    @discardableResult
    public func tokenize(
        request: POApplePayCardTokenizationRequest,
        completion: @escaping (Result<POCard, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await tokenize(request: request)
        }
    }
}

extension POCustomerTokensService {

    /// Assigns new source to existing customer token and optionally verifies it.
    @discardableResult
    public func assignCustomerToken(
        request: POAssignCustomerTokenRequest,
        threeDSService: PO3DSService,
        completion: @escaping (Result<POCustomerToken, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await assignCustomerToken(request: request, threeDSService: threeDSService)
        }
    }

    /// Creates customer token using given request.
    @_spi(PO)
    @discardableResult
    public func createCustomerToken(
        request: POCreateCustomerTokenRequest,
        completion: @escaping (Result<POCustomerToken, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await createCustomerToken(request: request)
        }
    }
}

extension POGatewayConfigurationsRepository {

    /// Returns available gateway configurations.
    @discardableResult
    public func all(
        request: POAllGatewayConfigurationsRequest,
        completion: @escaping (Result<POAllGatewayConfigurationsResponse, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await all(request: request)
        }
    }

    /// Searches configuration with given request.
    @discardableResult
    public func find(
        request: POFindGatewayConfigurationRequest,
        completion: @escaping (Result<POGatewayConfiguration, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await find(request: request)
        }
    }

    /// Returns available gateway configurations.
    @discardableResult
    public func all(
        completion: @escaping (Result<POAllGatewayConfigurationsResponse, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await all()
        }
    }
}

extension POImagesRepository {

    /// Attempts to download images at given URLs.
    @discardableResult
    public func images(
        at urls: [URL],
        scale: CGFloat,
        completion: @escaping ([URL: UIImage]) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            await images(at: urls, scale: scale)
        }
    }

    /// Attempts to download images at given URLs.
    @discardableResult
    public func images(
        at urls: [URL],
        completion: @escaping ([URL: UIImage]) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            await images(at: urls)
        }
    }

    /// Downloads image at given URL.
    @discardableResult
    public func image(
        at url: URL?,
        scale: CGFloat = 1,
        completion: @escaping (UIImage?) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            await image(at: url, scale: scale)
        }
    }

    /// Downloads two images at given URLs.
    @discardableResult
    public func images(
        at url1: URL?,
        _ url2: URL?,
        scale: CGFloat = 1,
        completion: @escaping ((UIImage?, UIImage?)) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            await images(at: url1, url2, scale: scale)
        }
    }

    /// Downloads image for given resource.
    @MainActor
    @discardableResult
    public func image(
        resource: POImageRemoteResource,
        completion: @escaping (UIImage?) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            await image(resource: resource)
        }
    }
}

extension POInvoicesService {

    /// Requests information needed to continue existing payment or start new one.
    @discardableResult
    public func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest,
        completion: @escaping (Result<PONativeAlternativePaymentMethodTransactionDetails, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await nativeAlternativePaymentMethodTransactionDetails(request: request)
        }
    }

    /// Initiates native alternative payment with a given request.
    /// 
    /// Some Native APMs require further information to be collected back from the customer. You can inspect
    /// `nativeApm` in response object to understand if additional data is required.
    @discardableResult
    public func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest,
        completion: @escaping (Result<PONativeAlternativePaymentMethodResponse, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await initiatePayment(request: request)
        }
    }

    /// Invoice details.
    @discardableResult
    public func invoice(
        request: POInvoiceRequest,
        completion: @escaping (Result<POInvoice, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await invoice(request: request)
        }
    }

    /// Performs invoice authorization with given request.
    @discardableResult
    public func authorizeInvoice(
        request: POInvoiceAuthorizationRequest,
        threeDSService: PO3DSService,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await authorizeInvoice(request: request, threeDSService: threeDSService)
        }
    }

    /// Captures native alternative payament.
    @discardableResult
    public func captureNativeAlternativePayment(
        request: PONativeAlternativePaymentCaptureRequest,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await captureNativeAlternativePayment(request: request)
        }
    }

    /// Creates invoice with given parameters.
    @_spi(PO)
    @discardableResult
    public func createInvoice(
        request: POInvoiceCreationRequest,
        completion: @escaping (Result<POInvoice, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await createInvoice(request: request)
        }
    }
}

/// Invokes given completion with a result of async operation.
private func invoke<T>(
    completion: @escaping (Result<T, POFailure>) -> Void,
    after operation: @escaping () async throws -> T
) -> POCancellable {
    Task { @MainActor in
        do {
            let returnValue = try await operation()
            completion(.success(returnValue))
        } catch let failure as POFailure {
            completion(.failure(failure))
        } catch {
            let failure = POFailure(code: .internal(.mobile), underlyingError: error)
            completion(.failure(failure))
        }
    }
}

/// Invokes given completion with a result of async operation.
private func invoke<T>(completion: @escaping (T) -> Void, after operation: @escaping () async -> T) -> Task<Void, Never> {
    Task { @MainActor in
        completion(await operation())
    }
}
