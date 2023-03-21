//
//  POInvoicesServiceType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

public protocol POInvoicesServiceType: POServiceType {

    /// Requests information needed to continue existing payment or start new one.
    func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest,
        completion: @escaping (Result<PONativeAlternativePaymentMethodTransactionDetails, Failure>) -> Void
    )

    /// Initiates native alternative payment with a given request.
    ///
    /// Some Native APMs require further information to be collected back from the customer. You can inspect
    /// `nativeApm` in response object to understand if additional data is required.
    func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest,
        completion: @escaping (Result<PONativeAlternativePaymentMethodResponse, Failure>) -> Void
    )

    /// Performs invoice authorization with given request.
    @_spi(PO)
    func authorizeInvoice(
        request: POInvoiceAuthorizationRequest,
        threeDSService: PO3DSServiceType,
        completion: @escaping (Result<Void, Failure>) -> Void
    )

    /// Captures native alternative payament.
    @discardableResult
    func captureNativeAlternativePayment(
        request: PONativeAlternativePaymentCaptureRequest, completion: @escaping (Result<Void, Failure>) -> Void
    ) -> POCancellableType

    /// Creates invoice with given parameters.
    @_spi(PO)
    func createInvoice(request: POInvoiceCreationRequest, completion: @escaping (Result<POInvoice, Failure>) -> Void)
}

extension POInvoicesServiceType {

    // swiftlint:disable:next unavailable_function
    func authorizeInvoice(
        request: POInvoiceAuthorizationRequest,
        threeDSService: PO3DSServiceType,
        completion: @escaping (Result<Void, Failure>) -> Void
    ) {
        fatalError("Not available!")
    }

    // swiftlint:disable:next unavailable_function
    func createInvoice(request: POInvoiceCreationRequest, completion: @escaping (Result<POInvoice, Failure>) -> Void) {
        fatalError("Not available!")
    }
}
