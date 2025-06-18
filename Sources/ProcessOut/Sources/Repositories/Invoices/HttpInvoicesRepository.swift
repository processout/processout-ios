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

    func createInvoice(request: POInvoiceCreationRequest) async throws -> POInvoice {
        struct Response: Decodable, Sendable {
            let invoice: POInvoice
        }
        let httpRequest = HttpConnectorRequest<Response>.post(
            path: "/invoices", body: request, includesDeviceMetadata: true, requiresPrivateKey: true
        )
        let response = try await connector.execute(request: httpRequest) as HttpConnectorResponse
        let clientSecret = response.headers["x-processout-client-secret"]
        return response.value.invoice.replacing(clientSecret: clientSecret)
    }

    func invoice(request: POInvoiceRequest) async throws -> POInvoice {
        struct Response: Decodable, Sendable {
            let invoice: POInvoice
        }
        let headers = [
            "X-Processout-Client-Secret": request.clientSecret
        ]
        let httpRequest = HttpConnectorRequest<Response>.get(
            path: "/invoices/\(request.invoiceId)",
            query: ["expand": "transaction"],
            headers: headers.compactMapValues { $0 },
            requiresPrivateKey: request.attachPrivateKey
        )
        let response = try await connector.execute(request: httpRequest) as HttpConnectorResponse
        let clientSecret = response.headers["x-processout-client-secret"]
        return response.value.invoice.replacing(clientSecret: clientSecret)
    }

    func authorizeInvoice(request: POInvoiceAuthorizationRequest) async throws -> _CustomerAction? {
        struct Response: Decodable, Sendable {
            let customerAction: _CustomerAction?
        }
        let headers = [
            "X-Processout-Client-Secret": request.clientSecret
        ]
        let httpRequest = HttpConnectorRequest<Response>.post(
            path: "/invoices/\(request.invoiceId)/authorize",
            body: request,
            headers: headers.compactMapValues { $0 },
            includesDeviceMetadata: true
        )
        return try await connector.execute(request: httpRequest).customerAction
    }

    func authorizeInvoice(
        request: PONativeAlternativePaymentAuthorizationRequestV2
    ) async throws -> PONativeAlternativePaymentAuthorizationResponseV2 {
        let httpRequest = HttpConnectorRequest<PONativeAlternativePaymentAuthorizationResponseV2>.post(
            path: "/invoices/\(request.invoiceId)/apm-payment", body: request
        )
        do {
            return try await connector.execute(request: httpRequest)
        } catch where request.shouldRecoverErrors {
            return try recoverResponse(from: error)
        }
    }

    // MARK: - Deprecated

    func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest
    ) async throws -> PONativeAlternativePaymentMethodTransactionDetails {
        struct Response: Decodable, Sendable {
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
        struct Request: Encodable, Sendable {
            struct NativeApm: Encodable, Sendable { // swiftlint:disable:this nesting
                let parameterValues: [String: String]
            }
            let gatewayConfigurationId: String
            let nativeApm: NativeApm
        }
        struct Response: Decodable, Sendable {
            let nativeApm: PONativeAlternativePaymentMethodResponse
        }
        let requestBox = Request(
            gatewayConfigurationId: request.gatewayConfigurationId,
            nativeApm: .init(parameterValues: request.parameters)
        )
        let httpRequest = HttpConnectorRequest<Response>.post(
            path: "/invoices/\(request.invoiceId)/native-payment", body: requestBox
        )
        return try await connector.execute(request: httpRequest).nativeApm
    }

    func captureNativeAlternativePayment(
        request: NativeAlternativePaymentCaptureRequest
    ) async throws -> PONativeAlternativePaymentMethodResponse {
        struct Response: Decodable, Sendable {
            let nativeApm: PONativeAlternativePaymentMethodResponse
        }
        let httpRequest = HttpConnectorRequest<Response>.post(
            path: "/invoices/\(request.invoiceId)/capture", body: request
        )
        return try await connector.execute(request: httpRequest).nativeApm
    }

    // MARK: - Private Properties

    private let connector: HttpConnector

    // MARK: - Private Methods

    private func recoverResponse(from error: Error) throws -> PONativeAlternativePaymentAuthorizationResponseV2 {
        guard let error = error as? POFailure,
              let underlyingError = error.underlyingError as? HttpConnectorFailure,
              let value = underlyingError.value as? PONativeAlternativePaymentAuthorizationResponseV2 else {
            throw error
        }
        return value
    }
}

private extension POInvoice { // swiftlint:disable:this no_extension_access_modifier

    func replacing(clientSecret newClientSecret: String?) -> Self {
        let updatedInvoice = POInvoice(
            id: id,
            amount: .init(value: amount),
            currency: currency,
            returnUrl: returnUrl,
            customerId: customerId,
            paymentMethods: paymentMethods,
            clientSecret: newClientSecret,
            transaction: transaction
        )
        return updatedInvoice
    }
}
