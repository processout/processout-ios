//
//  PO3DS2Service.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.09.2024.
//

/// This interface provides methods to process 3-D Secure transactions.
public protocol PO3DS2Service: AnyObject {

    /// Asks implementation to create request that will be passed to 3DS Server to create the AReq.
    func authenticationRequestParameters(
        configuration: PO3DS2Configuration
    ) async throws -> PO3DS2AuthenticationRequestParameters

    /// Implementation must handle given 3DS2 challenge.
    func performChallenge(with parameters: PO3DS2ChallengeParameters) async throws -> PO3DS2ChallengeResult
}
