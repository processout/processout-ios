//
//  InvoicesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2022.
//

import Foundation

final class InvoicesRepository: POInvoicesRepositoryType {

    init(connector: HttpConnectorType, failureMapper: RepositoryFailureMapperType) {
        self.connector = connector
        self.failureMapper = failureMapper
    }

    // MARK: - POInvoicesRepositoryType

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
        request: POInvoiceAuthorizationRequest, completion: @escaping (Result<POCustomerAction?, Failure>) -> Void
    ) {
        struct Response: Decodable {
            let customerAction: POCustomerAction?
        }
        let httpRequest = HttpConnectorRequest<Response>.post(
            path: "/invoices/\(request.invoiceId)/authorize", body: request, includesDeviceMetadata: true
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map(\.customerAction).mapError(failureMapper.repositoryFailure))
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
