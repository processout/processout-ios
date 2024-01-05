//
//  DefaultInvoicesService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

import Foundation

final class DefaultInvoicesService: POInvoicesService {

    init(repository: InvoicesRepository, threeDSService: ThreeDSService) {
        self.repository = repository
        self.threeDSService = threeDSService
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

    func authorizeInvoice(request: POInvoiceAuthorizationRequest, threeDSService: PO3DSService) async throws {
        guard let customerAction = try await repository.authorizeInvoice(request: request) else {
            return
        }
        let newSource = try await self.threeDSService.handle(action: customerAction, delegate: threeDSService)
        let newRequest = request.replacing(source: newSource)
        try await authorizeInvoice(request: newRequest, threeDSService: threeDSService)
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
                    return response.nativeApm.state != .captured
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
            timeoutError: POFailure(code: .timeout(.mobile)),
            retryStrategy: .linear(maximumRetries: .max, interval: 3)
        )
    }

    func createInvoice(request: POInvoiceCreationRequest) async throws -> POInvoice {
        try await repository.createInvoice(request: request)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let maximumCaptureTimeout: TimeInterval = 180
    }

    // MARK: - Private Properties

    private let repository: InvoicesRepository
    private let threeDSService: ThreeDSService
}

private extension POInvoiceAuthorizationRequest { // swiftlint:disable:this no_extension_access_modifier

    func replacing(source newSource: String) -> Self {
        let updatedRequest = POInvoiceAuthorizationRequest(
            invoiceId: invoiceId,
            source: newSource,
            incremental: incremental,
            enableThreeDS2: enableThreeDS2,
            preferredScheme: preferredScheme,
            thirdPartySdkVersion: thirdPartySdkVersion,
            invoiceDetailIds: invoiceDetailIds,
            overrideMacBlocking: overrideMacBlocking,
            initialSchemeTransactionId: initialSchemeTransactionId,
            autoCaptureAt: autoCaptureAt,
            captureAmount: captureAmount
        )
        return updatedRequest
    }
}
