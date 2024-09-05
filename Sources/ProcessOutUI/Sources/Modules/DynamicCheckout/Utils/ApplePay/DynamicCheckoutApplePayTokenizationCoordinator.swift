//
//  DynamicCheckoutApplePayTokenizationCoordinator.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.03.2024.
//

// todo(andrii-vysotskyi): use cards service instead of relying on session

import Foundation
import PassKit
import ProcessOut

final class DynamicCheckoutApplePayTokenizationCoordinator: POApplePayTokenizationDelegate {

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
