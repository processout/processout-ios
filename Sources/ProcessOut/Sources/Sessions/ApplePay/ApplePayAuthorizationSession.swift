//
//  ApplePayAuthorizationSession.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.09.2024.
//

import PassKit

protocol ApplePayAuthorizationSession: Sendable {

    /// Begins an Apple Pay payment authorization.
    /// - NOTE: delegate is retained for the duration of presentation.
    @MainActor
    func authorize(
        request: sending PKPaymentRequest, delegate: ApplePayAuthorizationSessionDelegate?
    ) async throws -> PKPayment
}
