//
//  PO3DSService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

@available(*, deprecated, renamed: "PO3DSService")
public typealias PO3DSServiceType = PO3DSService

/// This interface provides methods to process 3-D Secure transactions.
public protocol PO3DSService: AnyObject, Sendable {

    /// Asks implementation to create request that will be passed to 3DS Server to create the AReq.
    func authenticationRequestParameters(
        configuration: PO3DS2Configuration
    ) async throws -> PO3DS2AuthenticationRequestParameters

    /// Implementation must handle given 3DS2 challenge.
    func performChallenge(with parameters: PO3DS2ChallengeParameters) async throws -> PO3DS2ChallengeResult
}
