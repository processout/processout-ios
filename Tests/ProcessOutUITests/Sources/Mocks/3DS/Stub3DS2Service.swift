//
//  Stub3DS2Service.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.01.2025.
//

import ProcessOut

struct Stub3DS2Service: PO3DS2Service {

    let challengeResult: PO3DS2ChallengeResult, authenticationRequestParameters: PO3DS2AuthenticationRequestParameters

    // MARK: - PO3DS2Service

    func performChallenge(
        with parameters: PO3DS2ChallengeParameters
    ) async throws -> PO3DS2ChallengeResult {
        challengeResult
    }

    func authenticationRequestParameters(
        configuration: PO3DS2Configuration
    ) async throws -> PO3DS2AuthenticationRequestParameters {
        authenticationRequestParameters
    }
}
