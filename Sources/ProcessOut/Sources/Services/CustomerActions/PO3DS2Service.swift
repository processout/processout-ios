//
//  PO3DS2Service.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.09.2024.
//

/// This interface provides methods to process 3-D Secure transactions.
@preconcurrency
public protocol PO3DS2Service: Sendable {

    /// Returns the version of the 3DS SDK that is integrated with the 3DS Requestor App.
    nonisolated var version: String? { get }

    /// Asks implementation to create request that will be passed to 3DS Server to create the AReq.
    func authenticationRequestParameters(
        configuration: PO3DS2Configuration
    ) async throws -> PO3DS2AuthenticationRequestParameters

    /// Implementation must handle given 3DS2 challenge.
    func performChallenge(with parameters: PO3DS2ChallengeParameters) async throws -> PO3DS2ChallengeResult

    /// Allows the implementation to release any resources or reset its state after completing a 3DS session.
    func clean() async
}

extension PO3DS2Service {

    public nonisolated var version: String? {
        nil
    }

    public func clean() async {
        // Ignored
    }
}
