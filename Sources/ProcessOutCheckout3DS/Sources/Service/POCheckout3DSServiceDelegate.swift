//
//  POCheckout3DSServiceDelegate.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 01.03.2023.
//

import ProcessOut
import Checkout3DS

/// Checkout 3DS service delegate.
public protocol POCheckout3DSServiceDelegate: AnyObject, Sendable {

    /// Asks delegate whether service should continue with given warnings. Default implementation
    /// ignores warnings and returns `true`.
    func checkout3DSService(_ service: POCheckout3DSService, shouldContinueWith warnings: Set<Warning>) async -> Bool

    /// Notifies delegate that service is about to fingerprint device.
    ///
    /// Your implementation could change given `configuration` in case you want to
    /// customize underlying 3DS SDK appearance and behavior. Please note that
    /// `configParameters` should remain unchanged.
    @MainActor
    func checkout3DSService(
        _ service: POCheckout3DSService,
        willCreateAuthenticationRequestParametersWith configuration: inout ThreeDS2ServiceConfiguration
    )

    /// Notifies delegate that service failed to produce device fingerprint.
    @MainActor
    func checkout3DSService(
        _ service: POCheckout3DSService,
        didCreateAuthenticationRequestParameters result: Result<PO3DS2AuthenticationRequestParameters, POFailure>
    )

    /// Notifies delegate that implementation is about to proceed with 3DS2 challenge.
    @MainActor
    func checkout3DSService(
        _ service: POCheckout3DSService, willPerformChallengeWith parameters: PO3DS2ChallengeParameters
    )

    /// Notifies delegate that service did fail to handle 3DS2 challenge.
    @MainActor
    func checkout3DSService(
        _ service: POCheckout3DSService, didPerformChallenge result: Result<PO3DS2ChallengeResult, POFailure>
    )
}

extension POCheckout3DSServiceDelegate {

    public func checkout3DSService(
        _ service: POCheckout3DSService, shouldContinueWith warnings: Set<Warning>
    ) async -> Bool {
        true
    }

    @MainActor
    public func checkout3DSService(
        _ service: POCheckout3DSService,
        willCreateAuthenticationRequestParametersWith configuration: inout ThreeDS2ServiceConfiguration
    ) {
        // Ignored
    }

    @MainActor
    public func checkout3DSService(
        _ service: POCheckout3DSService,
        didCreateAuthenticationRequestParameters result: Result<PO3DS2AuthenticationRequestParameters, POFailure>
    ) {
        // Ignored
    }

    @MainActor
    public func checkout3DSService(
        _ service: POCheckout3DSService, willPerformChallengeWith parameters: PO3DS2ChallengeParameters
    ) {
        // Ignored
    }

    @MainActor
    public func checkout3DSService(
        _ service: POCheckout3DSService, didPerformChallenge result: Result<PO3DS2ChallengeResult, POFailure>
    ) {
        // Ignored
    }
}
