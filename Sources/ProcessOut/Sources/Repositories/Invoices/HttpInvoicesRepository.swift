//
//  HttpInvoicesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2022.
//

import Foundation

final class HttpInvoicesRepository: InvoicesRepository {

    init(connector: any HttpConnector<POFailure>) {
        self.connector = connector
    }

    // MARK: - InvoicesRepository

    func createInvoice(request: POInvoiceCreationRequest) async throws(POFailure) -> POInvoice {
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

    func invoice(request: POInvoiceRequest) async throws(POFailure) -> POInvoice {
        struct Response: Decodable, Sendable {
            let invoice: POInvoice
        }
        let headers = [
            "X-Processout-Client-Secret": request.clientSecret
        ]
        let httpRequest = HttpConnectorRequest<Response>.get(
            path: "/invoices/\(request.invoiceId)",
            query: [
                "expand": request.expand.map(\.rawValue).joined(separator: ",")
            ],
            headers: headers.compactMapValues { $0 },
            locale: request.localeIdentifier,
            requiresPrivateKey: request.attachPrivateKey
        )
        let response = try await connector.execute(request: httpRequest) as HttpConnectorResponse
        let clientSecret = response.headers["x-processout-client-secret"]
        return response.value.invoice.replacing(clientSecret: clientSecret)
    }

    func authorizeInvoice(
        request: POInvoiceAuthorizationRequest
    ) async throws(POFailure) -> InvoiceAuthorizationResponse {
        let headers = [
            "X-Processout-Client-Secret": request.clientSecret
        ]
        let httpRequest = HttpConnectorRequest<InvoiceAuthorizationResponse>.post(
            path: "/invoices/\(request.invoiceId)/authorize",
            body: request,
            headers: headers.compactMapValues { $0 },
            locale: request.localeIdentifier,
            includesDeviceMetadata: true
        )
        return try await connector.execute(request: httpRequest)
    }

    func authorizeInvoice(
        request: PONativeAlternativePaymentAuthorizationRequestV2
    ) async throws(POFailure) -> PONativeAlternativePaymentAuthorizationResponseV2 {
        let httpRequest = HttpConnectorRequest<PONativeAlternativePaymentAuthorizationResponseV2>.post(
            path: "/invoices/\(request.invoiceId)/apm-payment",
            body: request,
            locale: request.localeIdentifier
        )
        return try await connector.execute(request: httpRequest)
    }

    func resolveUrl(
        request: PONativeAlternativePaymentUrlResolutionRequestV2
    ) async throws(POFailure) -> PONativeAlternativePaymentUrlResolutionResponseV2 {
        let httpRequest = HttpConnectorRequest<PONativeAlternativePaymentUrlResolutionResponseV2>.post(
            path: "/apm-payments", body: request
        )
        return try await connector.execute(request: httpRequest)
    }

    func captureInvoice(request: POInvoiceCaptureRequest) async throws(POFailure) {
        struct Request: Encodable, Sendable {
            let source: String
        }
        let requestBox = Request(source: request.source)
        let httpRequest = HttpConnectorRequest<VoidCodable>.post(
            path: "/invoices/\(request.invoiceId)/capture", body: requestBox
        )
        _ = try await connector.execute(request: httpRequest)
    }

    // MARK: - Deprecated

    func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest
    ) async throws(POFailure) -> PONativeAlternativePaymentMethodTransactionDetails {
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
    ) async throws(POFailure) -> PONativeAlternativePaymentMethodResponse {
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
    ) async throws(POFailure) -> PONativeAlternativePaymentMethodResponse {
        struct Response: Decodable, Sendable {
            let nativeApm: PONativeAlternativePaymentMethodResponse
        }
        let httpRequest = HttpConnectorRequest<Response>.post(
            path: "/invoices/\(request.invoiceId)/capture", body: request
        )
        return try await connector.execute(request: httpRequest).nativeApm
    }

    // MARK: - Private Properties

    private let connector: any HttpConnector<POFailure>
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
