//
//  ApplePayAuthorizationSession.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.09.2024.
//

import PassKit

protocol ApplePayAuthorizationSession: Sendable {

    /// Begins an Apple Pay authorization.
    func authorize<T>(
        request: PKPaymentRequest,
        didAuthorizePayment: @escaping (PKPayment) async throws -> T,
        delegate: POApplePayAuthorizationSessionDelegate?
    ) async throws -> T
}
