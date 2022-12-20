//
//  InvoicesService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

import Foundation

final class InvoicesService: POInvoicesServiceType {

    init(
        repository: InvoicesRepositoryType,
        customerActionHandler: CustomerActionHandlerType,
        maximumCaptureTimeout: TimeInterval
    ) {
        self.repository = repository
        self.customerActionHandler = customerActionHandler
        self.maximumCaptureTimeout = maximumCaptureTimeout
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
        customerActionHandlerDelegate: POCustomerActionHandlerDelegate,
        completion: @escaping (Result<Void, Failure>) -> Void
    ) {
        repository.authorizeInvoice(request: request) { [customerActionHandler] result in
            switch result {
            case let .success(customerAction?):
                let delegate = customerActionHandlerDelegate
                customerActionHandler.handle(customerAction: customerAction, delegate: delegate) { result in
                    switch result {
                    case let .success(newSource):
                        self.authorizeInvoice(
                            request: request.replacing(source: newSource),
                            customerActionHandlerDelegate: customerActionHandlerDelegate,
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
    ) {
        let captureTimeout = min(request.timeout ?? maximumCaptureTimeout, maximumCaptureTimeout)
        let timer = Timer.scheduledTimer(withTimeInterval: captureTimeout, repeats: false) { _ in
            let failure = Failure(code: .timeout)
            completion(.failure(failure))
        }
        let request = NativeAlternativePaymentCaptureRequest(
            invoiceId: request.invoiceId, source: request.gatewayConfigurationId
        )
        var repositoryCompletion: ((Result<PONativeAlternativePaymentMethodResponse, POFailure>) -> Void)! // swiftlint:disable:this implicitly_unwrapped_optional line_length
        repositoryCompletion = { [repository] result in
            guard timer.isValid else {
                return
            }
            switch result {
            case let .success(response) where response.nativeApm.state == .captured:
                timer.invalidate()
                completion(.success(()))
            case .success, .failure:
                repository.captureNativeAlternativePayment(request: request, completion: repositoryCompletion)
            }
        }
        repository.captureNativeAlternativePayment(request: request, completion: repositoryCompletion)
    }

    func createInvoice(request: POInvoiceCreationRequest, completion: @escaping (Result<POInvoice, Failure>) -> Void) {
        repository.createInvoice(request: request, completion: completion)
    }

    // MARK: - Private Properties

    private let repository: InvoicesRepositoryType
    private let customerActionHandler: CustomerActionHandlerType
    private let maximumCaptureTimeout: TimeInterval
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
