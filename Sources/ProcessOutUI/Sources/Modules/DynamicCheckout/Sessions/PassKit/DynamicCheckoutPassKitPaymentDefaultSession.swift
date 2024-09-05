//
//  DynamicCheckoutPassKitPaymentDefaultSession.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.03.2024.
//

import Foundation
import PassKit
import ProcessOut

@MainActor
final class DynamicCheckoutPassKitPaymentDefaultSession: DynamicCheckoutPassKitPaymentSession {

    init(delegate: PODynamicCheckoutDelegate?, invoicesService: POInvoicesService) {
        self.delegate = delegate
        self.invoicesService = invoicesService
    }

    nonisolated var isSupported: Bool {
        PKPaymentAuthorizationController.canMakePayments()
    }

    func start(invoiceId: String, request: PKPaymentRequest) async throws {
        guard let delegate else {
            throw POFailure(message: "Delegate must be set to authorize invoice.", code: .generic(.mobile))
        }
        let tokenizationRequest = POApplePayTokenizationRequest(paymentRequest: request)
        let coordinator = TokenizationCoordinator { [invoicesService] card in
            var authorizationRequest = POInvoiceAuthorizationRequest(invoiceId: invoiceId, source: card.id)
            let threeDSService = await delegate.dynamicCheckout(willAuthorizeInvoiceWith: &authorizationRequest)
            try await invoicesService.authorizeInvoice(request: authorizationRequest, threeDSService: threeDSService)
        }
        // todo(andrii-vysotskyii): use injected card service
        _ = try await ProcessOut.shared.cards.tokenize(request: tokenizationRequest, delegate: coordinator)
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService
    private weak var delegate: PODynamicCheckoutDelegate?
}

private final class TokenizationCoordinator: POApplePayTokenizationDelegate {

    init(didTokenizeCard: @escaping (POCard) async throws -> Void) {
        self.didTokenizeCard = didTokenizeCard
    }

    /// Closure that is called when invoice is authorized.
    let didTokenizeCard: (POCard) async throws -> Void

    // MARK: -

    func applePayTokenization(
        didTokenizePayment payment: PKPayment, card: POCard
    ) async -> PKPaymentAuthorizationResult {
        do {
            try await didTokenizeCard(card)
        } catch {
            return .init(status: .failure, errors: [error])
        }
        return .init(status: .success, errors: nil)
    }
}
