//
//  InvoicesService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

import Foundation

final class InvoicesService: POInvoicesServiceType {

    init(repository: InvoicesRepositoryType, customerActionHandler: ThreeDSCustomerActionHandlerType) {
        self.repository = repository
        self.customerActionHandler = customerActionHandler
    }

    // MARK: - POCustomerTokensServiceType

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
        threeDSHandler: POThreeDSHandlerType,
        completion: @escaping (Result<Void, Failure>) -> Void
    ) {
        repository.authorizeInvoice(request: request) { [customerActionHandler] result in
            switch result {
            case let .success(customerAction?):
                customerActionHandler.handle(customerAction: customerAction, handler: threeDSHandler) { result in
                    switch result {
                    case let .success(newSource):
                        self.authorizeInvoice(
                            request: request.replacing(source: newSource),
                            threeDSHandler: threeDSHandler,
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
    ) -> POCancellableType {
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

    private let repository: InvoicesRepositoryType
    private let customerActionHandler: ThreeDSCustomerActionHandlerType
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
