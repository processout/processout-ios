//
//  DefaultNativeAlternativePaymentServiceAdapter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.06.2025.
//

import Foundation
@_spi(PO) import ProcessOut

final class DefaultNativeAlternativePaymentServiceAdapter: NativeAlternativePaymentServiceAdapter {

    init(
        invoicesService: POInvoicesService,
        tokensService: POCustomerTokensService,
        paymentConfirmationTimeout: TimeInterval
    ) {
        self.invoicesService = invoicesService
        self.tokensService = tokensService
        self.paymentConfirmationTimeout = paymentConfirmationTimeout
    }

    // MARK: - NativeAlternativePaymentAdapter

    func continuePayment(
        with request: NativeAlternativePaymentServiceAdapterRequest
    ) async throws -> NativeAlternativePaymentServiceAdapterResponse {
        switch request.flow {
        case .authorization(let flow):
            let authorizationRequest = PONativeAlternativePaymentAuthorizationRequestV2(
                invoiceId: flow.invoiceId,
                gatewayConfigurationId: flow.gatewayConfigurationId,
                source: flow.customerTokenId,
                submitData: request.submitData
            )
            let authorizationResponse = try await invoicesService.authorizeInvoice(request: authorizationRequest)
            return .init(authorizationResponse: authorizationResponse)
        case .tokenization(let flow):
            let tokenizationRequest = PONativeAlternativePaymentTokenizationRequestV2(
                customerId: flow.customerId,
                customerTokenId: flow.customerTokenId,
                gatewayConfigurationId: flow.gatewayConfigurationId,
                submitData: request.submitData
            )
            let tokenizationResponse = try await tokensService.tokenize(request: tokenizationRequest)
            return .init(tokenizationResponse: tokenizationResponse)
        }
    }

    func expectPaymentCompletion(
        with request: NativeAlternativePaymentServiceAdapterRequest
    ) async throws -> NativeAlternativePaymentServiceAdapterResponse {
        try await retry(
            operation: {
                try await self.continuePayment(with: request)
            },
            while: { result in
                switch result {
                case let .success(response):
                    return response.state != .success
                case let .failure(failure as POFailure):
                    let retriableCodes: [POFailureCode] = [
                        .Mobile.networkUnreachable, .Mobile.timeout, .Mobile.internal
                    ]
                    return retriableCodes.contains(failure.failureCode)
                case .failure:
                    return false
                }
            },
            timeout: min(paymentConfirmationTimeout, 15 * 60),
            timeoutError: POFailure(
                message: "Unable to confirm payment completion within the expected time.", code: .Mobile.timeout
            ),
            retryStrategy: .init(function: .exponential(interval: 0.15, rate: 1.45), minimum: 3, maximum: 90)
        )
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService
    private let tokensService: POCustomerTokensService
    private let paymentConfirmationTimeout: TimeInterval
}
