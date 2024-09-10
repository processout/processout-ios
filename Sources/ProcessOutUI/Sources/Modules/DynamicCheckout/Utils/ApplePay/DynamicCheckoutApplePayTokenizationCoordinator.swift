//
//  DynamicCheckoutApplePayTokenizationCoordinator.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.03.2024.
//

import Foundation
import PassKit
import ProcessOut

@MainActor
final class DynamicCheckoutApplePayTokenizationCoordinator: POApplePayTokenizationDelegate {

    nonisolated init(didTokenizeCard: @escaping (POCard) async throws -> Void) {
        self.didTokenizeCard = didTokenizeCard
    }

    /// Closure that is called when invoice is authorized.
    nonisolated(unsafe) private(set) var didTokenizeCard: (POCard) async throws -> Void

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
