//
//  Checkout3DSTransaction+Async.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 01.08.2024.
//

import Checkout3DS

extension Checkout3DS.Transaction {

    ///  Returns device and 3DS SDK information to the 3DS Requestor App.
    func getAuthenticationRequestParameters() async throws -> AuthenticationRequestParameters {
        try await withCheckedThrowingContinuation { continuation in
            getAuthenticationRequestParameters(completion: continuation.resume)
        }
    }

    /// Initiates the challenge process.
    func doChallenge(
        challengeParameters: ChallengeParameters
    ) async throws -> AuthenticationResult {
        try await withCheckedThrowingContinuation { continuation in
            doChallenge(challengeParameters: challengeParameters, completion: continuation.resume)
        }
    }
}
