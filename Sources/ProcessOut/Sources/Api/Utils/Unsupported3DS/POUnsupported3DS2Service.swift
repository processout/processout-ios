//
//  POUnsupported3DS2Service.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.09.2026.
//

/// Service that doesn't implement 3DS authentication and fails whenever one is requested. Intended for flows where
/// a 3DS challenge is not expected, for example an alternative payment authorization.
@_spi(PO)
public struct POUnsupported3DS2Service: PO3DS2Service {

    /// Creates service instance.
    public init() {
        // Ignored
    }

    // MARK: - PO3DS2Service

    public func authenticationRequestParameters(
        configuration: PO3DS2Configuration
    ) async throws -> PO3DS2AuthenticationRequestParameters {
        throw POFailure(
            message: "Unable to create authentication request parameters: 3DS is not supported.",
            code: .Mobile.generic
        )
    }

    public func performChallenge(with parameters: PO3DS2ChallengeParameters) async throws -> PO3DS2ChallengeResult {
        throw POFailure(
            message: "Unable to perform challenge: 3DS is not supported.",
            code: .Mobile.generic
        )
    }
}
