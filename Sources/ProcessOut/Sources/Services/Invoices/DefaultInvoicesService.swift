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

    func invoice(request: POInvoiceRequest) async throws -> POInvoice {
        try await repository.invoice(request: request)
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
                    let retriableCodes: [POFailure.Code] = [
                        .networkUnreachable, .timeout(.mobile), .internal(.mobile)
                    ]
                    return retriableCodes.contains(failure.code)
                case .failure:
                    return false
                }
            },
            timeout: captureTimeout,
            timeoutError: POFailure(
                message: "Unable to capture alternative payment within the expected time.", code: .timeout(.mobile)
            ),
            retryStrategy: .init(function: .exponential(interval: 0.15, rate: 1.45), minimum: 3, maximum: 90)
        )
    }

    func createInvoice(request: POInvoiceCreationRequest) async throws -> POInvoice {
        try await Task.sleep(seconds: 5)
        return try await repository.createInvoice(request: request)
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
        guard let customerAction = try await repository.authorizeInvoice(request: request) else {
            return
        }
        let newRequest: POInvoiceAuthorizationRequest
        do {
            let newSource = try await customerActionsService.handle(
                action: customerAction,
                threeDSService: threeDSService,
                webAuthenticationCallback: request.webAuthenticationCallback
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

    func replacing(source newSource: String) -> Self {
        let updatedRequest = POInvoiceAuthorizationRequest(
            invoiceId: invoiceId,
            source: newSource,
            saveSource: saveSource,
            incremental: incremental,
            preferredScheme: preferredScheme,
            thirdPartySdkVersion: thirdPartySdkVersion,
            invoiceDetailIds: invoiceDetailIds,
            overrideMacBlocking: overrideMacBlocking,
            initialSchemeTransactionId: initialSchemeTransactionId,
            autoCaptureAt: autoCaptureAt,
            captureAmount: captureAmount,
            authorizeOnly: authorizeOnly,
            allowFallbackToSale: allowFallbackToSale,
            clientSecret: clientSecret,
            metadata: metadata,
            webAuthenticationCallback: webAuthenticationCallback
        )
        return updatedRequest
    }
}
