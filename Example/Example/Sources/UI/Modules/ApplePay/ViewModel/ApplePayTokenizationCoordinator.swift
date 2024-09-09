//
//  ApplePayTokenizationCoordinator.swift
//  Example
//
//  Created by Andrii Vysotskyi on 05.09.2024.
//

import PassKit
import ProcessOut

final class ApplePayTokenizationCoordinator: POApplePayTokenizationDelegate {

    init(didTokenizeCard: @escaping (POCard) async throws -> Void) {
        self.didTokenizeCard = didTokenizeCard
    }

    /// Closure that is called when invoice is authorized.
    let didTokenizeCard: (POCard) async throws -> Void

    // MARK: -

    func applePayTokenization(
        didAuthorizePayment payment: PKPayment, card: POCard
    ) async -> PKPaymentAuthorizationResult {
        do {
            try await didTokenizeCard(card)
        } catch {
            return .init(status: .failure, errors: [error])
        }
        return .init(status: .success, errors: nil)
    }
}
