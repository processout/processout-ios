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

    /// Invoice details.
    func invoice(request: POInvoiceRequest) async throws -> POInvoice

    /// Performs invoice authorization with given request.
    func authorizeInvoice(request: POInvoiceAuthorizationRequest, threeDSService: PO3DSService) async throws

    /// Captures native alternative payament.
    func captureNativeAlternativePayment(request: PONativeAlternativePaymentCaptureRequest) async throws

    /// Creates invoice with given parameters.
    @_spi(PO)
    func createInvoice(request: POInvoiceCreationRequest) async throws -> POInvoice
}

extension POInvoicesService {

    @_spi(PO)
    public func createInvoice(request: POInvoiceCreationRequest) async throws -> POInvoice {
        throw POFailure(code: .generic(.mobile))
    }
}
