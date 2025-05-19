//
//  DefaultInvoicesService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

import Foundation

final class DefaultInvoicesService: POInvoicesService {

    init(repository: InvoicesRepository, customerActionsService: CustomerActionsService, logger: POLogger) {
        self.repository = repository
        self.customerActionsService = customerActionsService
        self.logger = logger
    }

    // MARK: - POInvoicesService

    func invoice(request: POInvoiceRequest) async throws -> POInvoice {
        try await repository.invoice(request: request)
    }

    func nativeAlternativePayment(
        request: PONativeAlternativePaymentRequest
    ) async throws -> PONativeAlternativePaymentAuthorizationResponse {
        try await repository.nativeAlternativePayment(request: request)
    }

    func authorizeInvoice(request: POInvoiceAuthorizationRequest, threeDSService: PO3DS2Service) async throws {
        do {
            try await _authorizeInvoice(request: request, threeDSService: threeDSService)
        } catch {
            await threeDSService.clean()
            throw error
        }
        await threeDSService.clean()
    }

    func authorizeInvoice(
        request: PONativeAlternativePaymentAuthorizationRequest
    ) async throws -> PONativeAlternativePaymentAuthorizationResponse {
        try await repository.authorizeInvoice(request: request)
    }

    func createInvoice(request: POInvoiceCreationRequest) async throws -> POInvoice {
        try await repository.createInvoice(request: request)
    }

    func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest
    ) async throws -> PONativeAlternativePaymentMethodTransactionDetails {
        try await repository.nativeAlternativePaymentMethodTransactionDetails(request: request)
    }

    func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest
    ) async throws -> PONativeAlternativePaymentMethodResponse {
        try await repository.initiatePayment(request: request)
    }

    func captureNativeAlternativePayment(request: PONativeAlternativePaymentCaptureRequest) async throws {
        let captureTimeout = min(request.timeout ?? .greatestFiniteMagnitude, Constants.maximumCaptureTimeout)
        _ = try await retry(
            operation: { [repository] in
                let request = NativeAlternativePaymentCaptureRequest(
                    invoiceId: request.invoiceId, source: request.gatewayConfigurationId
                )
                return try await repository.captureNativeAlternativePayment(request: request)
            },
            while: { result in
                switch result {
                case let .success(response):
                    return response.state != .captured
                case let .failure(failure as POFailure):
                    let retriableCodes: [POFailureCode] = [
                        .Mobile.networkUnreachable, .Mobile.timeout, .Mobile.internal
                    ]
                    return retriableCodes.contains(failure.failureCode)
                case .failure:
                    return false
                }
            },
            timeout: captureTimeout,
            timeoutError: POFailure(
                message: "Unable to capture alternative payment within the expected time.", code: .Mobile.timeout
            ),
            retryStrategy: .init(function: .exponential(interval: 0.15, rate: 1.45), minimum: 3, maximum: 90)
        )
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let maximumCaptureTimeout: TimeInterval = 60 * 15 // 15 minutes
    }

    // MARK: - Private Properties

    private let repository: InvoicesRepository
    private let customerActionsService: CustomerActionsService
    private let logger: POLogger

    // MARK: - Private Methods

    private func _authorizeInvoice(request: POInvoiceAuthorizationRequest, threeDSService: PO3DS2Service) async throws {
        let request = request.replacing(
            thirdPartySdkVersion: request.thirdPartySdkVersion ?? threeDSService.version
        )
        guard let customerAction = try await repository.authorizeInvoice(request: request) else {
            return
        }
        let newRequest: POInvoiceAuthorizationRequest
        do {
            let customerActionRequest = CustomerActionRequest(
                customerAction: customerAction,
                webAuthenticationCallback: request.webAuthenticationCallback,
                prefersEphemeralWebAuthenticationSession: request.prefersEphemeralWebAuthenticationSession
            )
            let newSource = try await customerActionsService.handle(
                request: customerActionRequest, threeDSService: threeDSService
            )
            newRequest = request.replacing(source: newSource)
        } catch {
            logger.warn("Did fail to authorize invoice: \(error)", attributes: [.invoiceId: request.invoiceId])
            throw error
        }
        try await _authorizeInvoice(request: newRequest, threeDSService: threeDSService)
    }
}

private extension POInvoiceAuthorizationRequest { // swiftlint:disable:this no_extension_access_modifier

    func replacing(source newSource: String? = nil, thirdPartySdkVersion newSdkVersion: String? = nil) -> Self {
        let updatedRequest = POInvoiceAuthorizationRequest(
            invoiceId: invoiceId,
            source: newSource ?? source,
            saveSource: saveSource,
            incremental: incremental,
            preferredScheme: $preferredScheme.typed,
            thirdPartySdkVersion: newSdkVersion ?? thirdPartySdkVersion,
            overrideMacBlocking: overrideMacBlocking,
            initialSchemeTransactionId: initialSchemeTransactionId,
            autoCaptureAt: autoCaptureAt,
            captureAmount: captureAmount,
            allowFallbackToSale: allowFallbackToSale,
            clientSecret: clientSecret,
            metadata: metadata,
            webAuthenticationCallback: webAuthenticationCallback
        )
        return updatedRequest
    }
}
