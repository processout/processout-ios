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

    /// Notifies delegate that service is about to fingerprint device.
    @MainActor
    func willCreateAuthenticationRequest(configuration: PO3DS2Configuration)

    /// Asks implementation to create `ThreeDS2ServiceConfiguration` using `configParameters`. This method
    /// could be used to customize underlying 3DS SDK appearance and behavior.
    @MainActor
    func configuration(
        with parameters: Checkout3DS.ThreeDS2ServiceConfiguration.ConfigParameters
    ) -> Checkout3DS.ThreeDS2ServiceConfiguration

    /// Asks delegate whether service should continue with given warnings. Default implementation
    /// ignores warnings and completes with `true`.
    func shouldContinue(with warnings: Set<Checkout3DS.Warning>) async -> Bool

    /// Notifies delegate that service did complete device fingerprinting.
    @MainActor
    func didCreateAuthenticationRequest(result: Result<PO3DS2AuthenticationRequest, POFailure>)

    /// Notifies delegate that implementation is about to handle 3DS2 challenge.
    @MainActor
    func willHandle(challenge: PO3DS2Challenge)

    /// Notifies delegate that service did end handling 3DS2 challenge with given result.
    @MainActor
    func didHandle3DS2Challenge(result: Result<Bool, POFailure>)
}
