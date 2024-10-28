//
//  Checkout3DSTransaction+Async.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2024.
//

import Checkout3DS

extension Checkout3DS.Transaction {

    func getAuthenticationRequestParameters() async throws -> AuthenticationRequestParameters {
        try await withCheckedThrowingContinuation { continuation in
            getAuthenticationRequestParameters { continuation.resume(with: $0) }
        }
    }

    func doChallenge(
        challengeParameters: ChallengeParameters
    ) async throws -> AuthenticationResult {
        try await withCheckedThrowingContinuation { continuation in
            doChallenge(challengeParameters: challengeParameters) { continuation.resume(with: $0) }
        }
    }
}
