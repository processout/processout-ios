//
//  InvoicesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2022.
//

protocol InvoicesRepository: PORepository {

    /// Requests information needed to continue existing payment or start new one.
    func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest
    ) async throws(Failure) -> PONativeAlternativePaymentMethodTransactionDetails

    /// Initiates native alternative payment with a given request.
    ///
    /// Some Native APMs require further information to be collected back from the customer. You can inspect
    /// `nativeApm` in response object to understand if additional data is required.
    func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest
    ) async throws(Failure) -> PONativeAlternativePaymentMethodResponse

    /// Invoice details.
    func invoice(request: POInvoiceRequest) async throws(Failure) -> POInvoice

    /// Performs invoice authorization with given request.
    func authorizeInvoice(request: POInvoiceAuthorizationRequest) async throws(Failure) -> _CustomerAction?

    /// Captures native alternative payment.
    func captureNativeAlternativePayment(
        request: NativeAlternativePaymentCaptureRequest
    ) async throws(Failure) -> PONativeAlternativePaymentMethodResponse

    /// Creates invoice with given parameters.
    func createInvoice(request: POInvoiceCreationRequest) async throws(Failure) -> POInvoice
}
