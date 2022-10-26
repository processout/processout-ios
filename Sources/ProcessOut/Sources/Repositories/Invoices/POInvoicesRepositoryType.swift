//
//  POInvoicesRepositoryType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2022.
//

public protocol POInvoicesRepositoryType: PORepositoryType {

    /// Initiates native alternative payment with a given request.
    ///
    /// Some Native APMs require further information to be collected back from the customer. You can inspect
    /// `nativeApm` in response object to understand if additional data is required.
    func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest,
        completion: @escaping (Result<PONativeAlternativePaymentMethodResponse, Failure>) -> Void
    )

    /// Performs invoice authorization with given request.
    func authorizeInvoice(
        request: POInvoiceAuthorizationRequest, completion: @escaping (Result<POCustomerAction?, Failure>) -> Void
    )

    /// Creates invoice with given parameters.
    @_spi(PO)
    func createInvoice(request: POInvoiceCreationRequest, completion: @escaping (Result<POInvoice, Failure>) -> Void)
}
