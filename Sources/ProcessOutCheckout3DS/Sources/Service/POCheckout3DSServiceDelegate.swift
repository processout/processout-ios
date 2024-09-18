//
//  POCheckout3DSServiceDelegate.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 01.03.2023.
//

import ProcessOut
import Checkout3DS

/// Checkout 3DS service delegate.
public protocol POCheckout3DSServiceDelegate: AnyObject {

    /// Notifies delegate that service is about to fingerprint device.
    func willCreateAuthenticationRequest(configuration: PO3DS2Configuration)

    /// Asks implementation to create `ThreeDS2ServiceConfiguration` using `configParameters`. This method
    /// could be used to customize underlying 3DS SDK appearance and behavior.
    func configuration(
        with parameters: Checkout3DS.ThreeDS2ServiceConfiguration.ConfigParameters
    ) -> Checkout3DS.ThreeDS2ServiceConfiguration

    /// Asks delegate whether service should continue with given warnings. Default implementation
    /// ignores warnings and completes with `true`.
    func shouldContinue(with warnings: Set<Checkout3DS.Warning>, completion: @escaping (Bool) -> Void)

    /// Notifies delegate that service did complete device fingerprinting.
    func didCreateAuthenticationRequest(result: Result<PO3DS2AuthenticationRequest, POFailure>)

    /// Notifies delegate that implementation is about to handle 3DS2 challenge.
    func willHandle(challenge: PO3DS2Challenge)

    /// Notifies delegate that service did end handling 3DS2 challenge with given result.
    func didHandle3DS2Challenge(result: Result<Bool, POFailure>)

    /// Asks delegate to handle 3DS redirect. See documentation of `PO3DSService/handle(redirect:completion:)`
    /// for more details.
    @available(*, deprecated, message: "Redirects are handled internally.")
    func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void)
}

extension POCheckout3DSServiceDelegate {

    public func willCreateAuthenticationRequest(configuration: PO3DS2Configuration) {
        // Ignored
    }

    public func configuration(
        with parameters: Checkout3DS.ThreeDS2ServiceConfiguration.ConfigParameters
    ) -> Checkout3DS.ThreeDS2ServiceConfiguration {
        ThreeDS2ServiceConfiguration(configParameters: parameters)
    }

    public func didCreateAuthenticationRequest(result: Result<PO3DS2AuthenticationRequest, POFailure>) {
        // Ignored
    }

    public func willHandle(challenge: PO3DS2Challenge) {
        // Ignored
    }

    public func didHandle3DS2Challenge(result: Result<Bool, POFailure>) {
        // Ignored
    }

    public func shouldContinue(with warnings: Set<Checkout3DS.Warning>, completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    @available(*, deprecated, message: "Redirects are handled internally.")
    public func handle( // swiftlint:disable:this unavailable_function
        redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void
    ) {
        preconditionFailure("Should never be called.")
    }
}
