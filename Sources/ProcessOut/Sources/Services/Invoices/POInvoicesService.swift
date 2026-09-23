//
//  POInvoicesService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

// todo(andrii-vysotskyi): potentially make threeDSService optional to allow easier APMs authorization

@available(*, deprecated, renamed: "POInvoicesService")
public typealias POInvoicesServiceType = POInvoicesService

public protocol POInvoicesService: POService { // sourcery: AutoCompletion

    /// Creates invoice with given parameters.
    @_spi(PO)
    func createInvoice(request: POInvoiceCreationRequest) async throws(POFailure) -> POInvoice

    /// Invoice details.
    func invoice(request: POInvoiceRequest) async throws(POFailure) -> POInvoice

    /// Performs invoice authorization with given request.
    func authorizeInvoice(request: POInvoiceAuthorizationRequest, threeDSService: PO3DS2Service) async throws(POFailure)

    /// Performs invoice authorization with given request.
    @_disfavoredOverload
    func authorizeInvoice(
        request: POInvoiceAuthorizationRequest, threeDSService: PO3DS2Service
    ) async throws(POFailure) -> POInvoiceAuthorizationResponse

    /// Performs invoice authorization using given alternative payment method details.
    func authorizeInvoice( // sourcery:completion: skip
        request: PONativeAlternativePaymentAuthorizationRequestV2
    ) async throws(POFailure) -> PONativeAlternativePaymentAuthorizationResponseV2

    /// Resolves native alternative payment return URL.
    @_spi(PO)
    func resolveUrl( // sourcery:completion: skip
        request: PONativeAlternativePaymentUrlResolutionRequestV2
    ) async throws(POFailure) -> PONativeAlternativePaymentUrlResolutionResponseV2

    /// Captures invoice with a given request.
    ///
    /// Unlike ``captureNativeAlternativePayment(request:)`` capture is attempted only once, so method either
    /// succeeds or fails.
    @_spi(PO)
    func captureInvoice(request: POInvoiceCaptureRequest) async throws(POFailure) // sourcery:completion: skip

    // MARK: - Alternative Payment (Deprecated)

    /// Requests information needed to continue existing payment or start new one.
    func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest
    ) async throws(POFailure) -> PONativeAlternativePaymentMethodTransactionDetails

    /// Initiates native alternative payment with a given request.
    ///
    /// Some Native APMs require further information to be collected back from the customer. You can inspect
    /// `nativeApm` in response object to understand if additional data is required.
    func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest
    ) async throws(POFailure) -> PONativeAlternativePaymentMethodResponse

    /// Captures native alternative payament.
    func captureNativeAlternativePayment(request: PONativeAlternativePaymentCaptureRequest) async throws(POFailure)
}

extension POInvoicesService {

    /// Performs invoice authorization with given request.
    public func authorizeInvoice(
        request: POInvoiceAuthorizationRequest, threeDSService: PO3DS2Service
    ) async throws(POFailure) {
        _ = try await authorizeInvoice(
            request: request, threeDSService: threeDSService
        ) as POInvoiceAuthorizationResponse
    }

    @_spi(PO)
    public func createInvoice(request: POInvoiceCreationRequest) async throws(POFailure) -> POInvoice {
        throw POFailure(code: .Mobile.generic)
    }

    @_spi(PO)
    public func resolveUrl(
        request: PONativeAlternativePaymentUrlResolutionRequestV2
    ) async throws(POFailure) -> PONativeAlternativePaymentUrlResolutionResponseV2 {
        throw POFailure(code: .Mobile.generic)
    }

    @_spi(PO)
    public func captureInvoice(request: POInvoiceCaptureRequest) async throws(POFailure) {
        throw POFailure(code: .Mobile.generic)
    }
}
