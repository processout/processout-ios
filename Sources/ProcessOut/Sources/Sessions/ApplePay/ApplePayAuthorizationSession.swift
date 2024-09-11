//
//  ApplePayAuthorizationSession.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.09.2024.
//

import PassKit

@MainActor
protocol ApplePayAuthorizationSession: Sendable {

    /// Begins an Apple Pay payment authorization.
    /// - NOTE: delegate is retained for the duration of presentation.
    func authorize(
        request: PKPaymentRequest, delegate: ApplePayAuthorizationSessionDelegate?
    ) async throws -> PKPayment
}
