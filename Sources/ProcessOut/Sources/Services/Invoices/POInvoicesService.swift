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

    /// Invoice details.
    func invoice(request: POInvoiceRequest) async throws -> POInvoice

    /// Returns native alternative payment details.
    @_spi(PO)
    func nativeAlternativePayment( // sourcery:completion: skip
        request: PONativeAlternativePaymentAuthorizationDetailsRequest
    ) async throws -> PONativeAlternativePaymentAuthorizationResponseV2

    /// Performs invoice authorization with given request.
    func authorizeInvoice(request: POInvoiceAuthorizationRequest, threeDSService: PO3DS2Service) async throws

    /// Performs invoice authorization using given alternative payment method details.
    @_spi(PO)
    func authorizeInvoice( // sourcery:completion: skip
        request: PONativeAlternativePaymentAuthorizationRequestV2
    ) async throws -> PONativeAlternativePaymentAuthorizationResponseV2

    /// Creates invoice with given parameters.
    @_spi(PO)
    func createInvoice(request: POInvoiceCreationRequest) async throws -> POInvoice

    // MARK: - Alternative Payment (Deprecated)

    /// Requests information needed to continue existing payment or start new one.
    func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest
    ) async throws -> PONativeAlternativePaymentMethodTransactionDetails

    /// Initiates native alternative payment with a given request.
    ///
    /// Some Native APMs require further information to be collected back from the customer. You can inspect
    /// `nativeApm` in response object to understand if additional data is required.
    func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest
    ) async throws -> PONativeAlternativePaymentMethodResponse

    /// Captures native alternative payament.
    func captureNativeAlternativePayment(request: PONativeAlternativePaymentCaptureRequest) async throws
}

extension POInvoicesService {

    @_spi(PO)
    public func nativeAlternativePayment(
        request: PONativeAlternativePaymentAuthorizationDetailsRequest
    ) async throws -> PONativeAlternativePaymentAuthorizationResponseV2 {
        throw POFailure(code: .Mobile.generic)
    }

    @_spi(PO)
    public func authorizeInvoice(
        request: PONativeAlternativePaymentAuthorizationRequestV2
    ) async throws -> PONativeAlternativePaymentAuthorizationResponseV2 {
        throw POFailure(code: .Mobile.generic)
    }

    @_spi(PO)
    public func createInvoice(request: POInvoiceCreationRequest) async throws -> POInvoice {
        throw POFailure(code: .Mobile.generic)
    }
}
