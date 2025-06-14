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
        // todo(andrii-vysotskyi): support PENDING state
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService
    private let tokensService: POCustomerTokensService
    private let paymentConfirmationTimeout: TimeInterval
}
