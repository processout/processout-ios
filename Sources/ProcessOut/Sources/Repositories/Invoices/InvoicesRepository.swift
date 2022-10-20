//
//  InvoicesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2022.
//

import Foundation

final class InvoicesRepository: POInvoicesRepositoryType {

    init(connector: HttpConnectorType, failureFactory: RepositoryFailureFactoryType) {
        self.connector = connector
        self.failureFactory = failureFactory
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
        connector.execute(request: httpRequest) { [failureFactory] result in
            completion(result.mapError(failureFactory.repositoryFailure))
        }
    }

    // MARK: - Private Nested Types

    private struct NativeAlternativePaymentRequestBox: Encodable {
        struct NativeApm: Encodable { // swiftlint:disable:this nesting
            let parameterValues: [String: PONativeAlternativePaymentMethodRequest.ParameterValue]
        }
        let gatewayConfigurationId: String
        let nativeApm: NativeApm
    }

    // MARK: - Private Properties

    private let connector: HttpConnectorType
    private let failureFactory: RepositoryFailureFactoryType
}
