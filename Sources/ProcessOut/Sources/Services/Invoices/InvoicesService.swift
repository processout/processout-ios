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

    // MARK: - POCustomerTokensService

    func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest,
        completion: @escaping (Result<PONativeAlternativePaymentMethodTransactionDetails, Failure>) -> Void
    ) {
        repository.nativeAlternativePaymentMethodTransactionDetails(request: request, completion: completion)
    }

    func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest,
        completion: @escaping (Result<PONativeAlternativePaymentMethodResponse, Failure>) -> Void
    ) {
        repository.initiatePayment(request: request, completion: completion)
    }

    func authorizeInvoice(
        request: POInvoiceAuthorizationRequest,
        threeDSService threeDSServiceDelegate: PO3DSService,
        completion: @escaping (Result<Void, Failure>) -> Void
    ) {
        repository.authorizeInvoice(request: request) { [threeDSService] result in
            switch result {
            case let .success(customerAction?):
                threeDSService.handle(action: customerAction, delegate: threeDSServiceDelegate) { result in
                    switch result {
                    case let .success(newSource):
                        self.authorizeInvoice(
                            request: request.replacing(source: newSource),
                            threeDSService: threeDSServiceDelegate,
                            completion: completion
                        )
                    case let .failure(failure):
                        completion(.failure(failure))
                    }
                }
            case .success:
                completion(.success(()))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    func captureNativeAlternativePayment(
        request: PONativeAlternativePaymentCaptureRequest, completion: @escaping (Result<Void, Failure>) -> Void
    ) -> POCancellable {
        let captureTimeout = min(request.timeout ?? Constants.maximumCaptureTimeout, Constants.maximumCaptureTimeout)
        let request = NativeAlternativePaymentCaptureRequest(
            invoiceId: request.invoiceId, source: request.gatewayConfigurationId
        )
        let pollingOperation = PollingOperation(
            timeout: captureTimeout,
            executeDelay: Constants.captureRetryDelay,
            execute: { [repository] completion in
                repository.captureNativeAlternativePayment(request: request, completion: completion)
            },
            shouldContinue: { result in
                switch result {
                case let .success(response):
                    return response.nativeApm.state != .captured
                case let .failure(failure):
                    let retriableCodes: [POFailure.Code] = [
                        .networkUnreachable, .timeout(.mobile), .internal(.mobile)
                    ]
                    return retriableCodes.contains(failure.code)
                }
            },
            completion: { result in
                completion(result.map { _ in () })
            }
        )
        pollingOperation.start()
        return pollingOperation
    }

    func createInvoice(request: POInvoiceCreationRequest, completion: @escaping (Result<POInvoice, Failure>) -> Void) {
        repository.createInvoice(request: request, completion: completion)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let maximumCaptureTimeout: TimeInterval = 180
        static let captureRetryDelay: TimeInterval = 3
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
