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
    ) async throws -> PONativeAlternativePaymentMethodTransactionDetails

    /// Initiates native alternative payment with a given request.
    ///
    /// Some Native APMs require further information to be collected back from the customer. You can inspect
    /// `nativeApm` in response object to understand if additional data is required.
    func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest
    ) async throws -> PONativeAlternativePaymentMethodResponse

    /// Performs invoice authorization with given request.
    func authorizeInvoice(request: POInvoiceAuthorizationRequest) async throws -> ThreeDSCustomerAction?

    /// Captures native alternative payment.
    func captureNativeAlternativePayment(
        request: NativeAlternativePaymentCaptureRequest
    ) async throws -> PONativeAlternativePaymentMethodResponse

    /// Creates invoice with given parameters.
    func createInvoice(request: POInvoiceCreationRequest) async throws -> POInvoice
}
