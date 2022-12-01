//
//  InvoicesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2022.
//

import Foundation

final class InvoicesRepository: InvoicesRepositoryType {

    init(connector: HttpConnectorType, failureMapper: RepositoryFailureMapperType) {
        self.connector = connector
        self.failureMapper = failureMapper
    }

    // MARK: - POInvoicesRepositoryType

    func nativeAlternativePaymentMethodTransactionDetails(
        invoiceId: String,
        gatewayConfigurationId: String,
        completion: @escaping (Result<PONativeAlternativePaymentMethodTransactionDetails, Failure>) -> Void
    ) {
        struct Response: Decodable {
            let nativeApm: PONativeAlternativePaymentMethodTransactionDetails
        }
        let httpRequest = HttpConnectorRequest<Response>.get(
            path: "/invoices/\(invoiceId)/native-payment/\(gatewayConfigurationId)"
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map(\.nativeApm).mapError(failureMapper.repositoryFailure))
        }
    }

    func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest,
        completion: @escaping (Result<PONativeAlternativePaymentMethodResponse, Failure>) -> Void
    ) {
        let requestBox = NativeAlternativePaymentRequestBox(
            gatewayConfigurationId: request.gatewayConfigurationId,
            nativeApm: .init(parameterValues: request.parameters)
        )
        let httpRequest = HttpConnectorRequest<PONativeAlternativePaymentMethodResponse>.post(
            path: "/invoices/\(request.invoiceId)/native-payment", body: requestBox
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.mapError(failureMapper.repositoryFailure))
        }
    }

    func authorizeInvoice(
        request: POInvoiceAuthorizationRequest, completion: @escaping (Result<CustomerAction?, Failure>) -> Void
    ) {
        struct Response: Decodable {
            let customerAction: CustomerAction?
        }
        let httpRequest = HttpConnectorRequest<Response>.post(
            path: "/invoices/\(request.invoiceId)/authorize", body: request, includesDeviceMetadata: true
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map(\.customerAction).mapError(failureMapper.repositoryFailure))
        }
    }

    func capture(invoiceId: String, completion: @escaping (Result<Void, Failure>) -> Void) {
        let httpRequest = HttpConnectorRequest<VoidCodable>.post(
            path: "/invoices/\(invoiceId)/capture", body: nil as AnyEncodable?
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map { _ in () }.mapError(failureMapper.repositoryFailure))
        }
    }

    func createInvoice(request: POInvoiceCreationRequest, completion: @escaping (Result<POInvoice, Failure>) -> Void) {
        struct Response: Decodable {
            let invoice: POInvoice
        }
        let httpRequest = HttpConnectorRequest<Response>.post(path: "/invoices", body: request)
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map(\.invoice).mapError(failureMapper.repositoryFailure))
        }
    }

    // MARK: - Private Nested Types

    private struct NativeAlternativePaymentRequestBox: Encodable {
        struct NativeApm: Encodable { // swiftlint:disable:this nesting
            let parameterValues: [String: String]
        }
        let gatewayConfigurationId: String
        let nativeApm: NativeApm
    }

    // MARK: - Private Properties

    private let connector: HttpConnectorType
    private let failureMapper: RepositoryFailureMapperType
}
