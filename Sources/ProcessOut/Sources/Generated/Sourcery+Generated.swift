// Generated using Sourcery 2.1.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

@available(iOS 13.0, *)
extension POCardsService {

    /// Tokenizes a card. You can use the card for a single payment by creating a card token with it. If you want
    /// to use the card for multiple payments then you can use the card token to create a reusable customer token.
    /// Note that once you have used the card token either for a payment or to create a customer token, the card
    /// token becomes invalid and you cannot use it for any further actions.
    @MainActor
    public func tokenize(
        request: POCardTokenizationRequest
    ) async throws -> POCard {
        return try await withUnsafeThrowingContinuation { continuation in
            tokenize(request: request, completion: continuation.resume)
        }
    }

    /// Updates card information.
    @MainActor
    public func updateCard(
        request: POCardUpdateRequest
    ) async throws -> POCard {
        return try await withUnsafeThrowingContinuation { continuation in
            updateCard(request: request, completion: continuation.resume)
        }
    }

    /// Tokenize a card via ApplePay. You can use the card for a single payment by creating a card token with it.
    @MainActor
    public func tokenize(
        request: POApplePayCardTokenizationRequest
    ) async throws -> POCard {
        return try await withUnsafeThrowingContinuation { continuation in
            tokenize(request: request, completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension POCustomerTokensService {

    /// Assigns new source to existing customer token and optionaly verifies it.
    @MainActor
    public func assignCustomerToken(
        request: POAssignCustomerTokenRequest, threeDSService: PO3DSService
    ) async throws -> POCustomerToken {
        return try await withUnsafeThrowingContinuation { continuation in
            assignCustomerToken(request: request, threeDSService: threeDSService, completion: continuation.resume)
        }
    }

    /// Creates customer token using given request.
    @MainActor
    @_spi(PO)
    public func createCustomerToken(
        request: POCreateCustomerTokenRequest
    ) async throws -> POCustomerToken {
        return try await withUnsafeThrowingContinuation { continuation in
            createCustomerToken(request: request, completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension POInvoicesService {

    /// Requests information needed to continue existing payment or start new one.
    @MainActor
    public func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest
    ) async throws -> PONativeAlternativePaymentMethodTransactionDetails {
        return try await withUnsafeThrowingContinuation { continuation in
            nativeAlternativePaymentMethodTransactionDetails(request: request, completion: continuation.resume)
        }
    }

    /// Initiates native alternative payment with a given request.
    /// 
    /// Some Native APMs require further information to be collected back from the customer. You can inspect
    /// `nativeApm` in response object to understand if additional data is required.
    @MainActor
    public func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest
    ) async throws -> PONativeAlternativePaymentMethodResponse {
        return try await withUnsafeThrowingContinuation { continuation in
            initiatePayment(request: request, completion: continuation.resume)
        }
    }

    /// Performs invoice authorization with given request.
    @MainActor
    public func authorizeInvoice(
        request: POInvoiceAuthorizationRequest, threeDSService: PO3DSService
    ) async throws -> Void {
        return try await withUnsafeThrowingContinuation { continuation in
            authorizeInvoice(request: request, threeDSService: threeDSService, completion: continuation.resume)
        }
    }

    /// Creates invoice with given parameters.
    @MainActor
    @_spi(PO)
    public func createInvoice(
        request: POInvoiceCreationRequest
    ) async throws -> POInvoice {
        return try await withUnsafeThrowingContinuation { continuation in
            createInvoice(request: request, completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension POService {
}

import Foundation
import UIKit

// swiftlint:disable all

extension CardsRepository {

    /// Allows to retrieve card issuer information based on iin.
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

    /// Tokenize a card.
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

    /// Tokenize a card via ApplePay.
    @discardableResult
    public func tokenize(
        request: ApplePayCardTokenizationRequest,
        completion: @escaping (Result<POCard, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await tokenize(request: request)
        }
    }
}

extension CustomerTokensRepository {

    /// Assigns a token to a customer.
    @discardableResult
    public func assignCustomerToken(
        request: POAssignCustomerTokenRequest,
        completion: @escaping (Result<AssignCustomerTokenResponse, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await assignCustomerToken(request: request)
        }
    }

    /// Create customer token.
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

extension ImagesRepository {

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

    /// Downloads image at given URL and calls completion.
    @discardableResult
    public func image(
        at url: URL?,
        completion: @escaping (UIImage?) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            await image(at: url)
        }
    }

    /// Downloads two images at given URLs and calls completion.
    @discardableResult
    public func images(
        at url1: URL?,
        _ url2: URL?,
        completion: @escaping ((UIImage?, UIImage?)) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            await images(at: url1, url2)
        }
    }
}

extension InvoicesRepository {

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

    /// Performs invoice authorization with given request.
    @discardableResult
    public func authorizeInvoice(
        request: POInvoiceAuthorizationRequest,
        completion: @escaping (Result<ThreeDSCustomerAction?, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await authorizeInvoice(request: request)
        }
    }

    /// Captures native alternative payment.
    @discardableResult
    public func captureNativeAlternativePayment(
        request: NativeAlternativePaymentCaptureRequest,
        completion: @escaping (Result<PONativeAlternativePaymentMethodResponse, POFailure>) -> Void
    ) -> POCancellable {
        invoke(completion: completion) {
            try await captureNativeAlternativePayment(request: request)
        }
    }

    /// Creates invoice with given parameters.
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

extension LogsRepository {
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

extension PORepository {
}
