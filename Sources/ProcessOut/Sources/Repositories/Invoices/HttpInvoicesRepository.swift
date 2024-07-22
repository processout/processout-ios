//
//  HttpInvoicesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2022.
//

import Foundation

final class HttpInvoicesRepository: InvoicesRepository {

    init(connector: HttpConnector) {
        self.connector = connector
    }

    // MARK: - InvoicesRepository

    func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest
    ) async throws -> PONativeAlternativePaymentMethodTransactionDetails {
        struct Response: Decodable {
            let nativeApm: PONativeAlternativePaymentMethodTransactionDetails
        }
        let httpRequest = HttpConnectorRequest<Response>.get(
            path: "/invoices/\(request.invoiceId)/native-payment/\(request.gatewayConfigurationId)"
        )
        return try await connector.execute(request: httpRequest).nativeApm
    }

    func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest
    ) async throws -> PONativeAlternativePaymentMethodResponse {
        let requestBox = NativeAlternativePaymentRequestBox(
            gatewayConfigurationId: request.gatewayConfigurationId,
            nativeApm: .init(parameterValues: request.parameters)
        )
        let httpRequest = HttpConnectorRequest<PONativeAlternativePaymentMethodResponse>.post(
            path: "/invoices/\(request.invoiceId)/native-payment", body: requestBox
        )
        return try await connector.execute(request: httpRequest)
    }

    func invoice(request: POInvoiceRequest) async throws -> POInvoice {
        struct Response: Decodable {
            let invoice: POInvoice
        }
        let headers = [
            "X-Processout-Client-Secret": request.clientSecret
        ]
        let httpRequest = HttpConnectorRequest<Response>.get(
            path: "/invoices/\(request.id)",
            headers: headers.compactMapValues { $0 }
        )
        return try await connector.execute(request: httpRequest).invoice
    }

    func authorizeInvoice(request: POInvoiceAuthorizationRequest) async throws -> ThreeDSCustomerAction? {
        struct Response: Decodable {
            let customerAction: ThreeDSCustomerAction?
        }
        let httpRequest = HttpConnectorRequest<Response>.post(
            path: "/invoices/\(request.invoiceId)/authorize", body: request, includesDeviceMetadata: true
        )
        return try await connector.execute(request: httpRequest).customerAction
    }

    func captureNativeAlternativePayment(
        request: NativeAlternativePaymentCaptureRequest
    ) async throws -> PONativeAlternativePaymentMethodResponse {
        let httpRequest = HttpConnectorRequest<PONativeAlternativePaymentMethodResponse>.post(
            path: "/invoices/\(request.invoiceId)/capture", body: request
        )
        return try await connector.execute(request: httpRequest)
    }

    func createInvoice(request: POInvoiceCreationRequest) async throws -> POInvoice {
        struct Response: Decodable {
            let invoice: POInvoice
        }
        let httpRequest = HttpConnectorRequest<Response>.post(
            path: "/invoices", body: request, includesDeviceMetadata: true, requiresPrivateKey: true
        )
        return try await connector.execute(request: httpRequest).invoice
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

    private let connector: HttpConnector
}
