//
//  InvoicesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2022.
//

protocol InvoicesRepository: PORepository {

    /// Invoice details.
    func invoice(request: POInvoiceRequest) async throws -> POInvoice

    /// Returns alternative payment details.
    func nativeAlternativePayment(
        request: PONativeAlternativePaymentRequest
    ) async throws -> PONativeAlternativePaymentAuthorizationResponse

    /// Continue alternative payment.
    func authorizeInvoice(
        request: PONativeAlternativePaymentAuthorizationRequest
    ) async throws -> PONativeAlternativePaymentAuthorizationResponse

    /// Performs invoice authorization with given request.
    func authorizeInvoice(request: POInvoiceAuthorizationRequest) async throws -> _CustomerAction?

    /// Creates invoice with given parameters.
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

    /// Captures native alternative payment.
    func captureNativeAlternativePayment(
        request: NativeAlternativePaymentCaptureRequest
    ) async throws -> PONativeAlternativePaymentMethodResponse
}
