//
//  POCheckout3DSServiceDelegate.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 01.03.2023.
//

import ProcessOutCore
import Checkout3DS

/// Checkout 3DS service delegate.
@preconcurrency
public protocol POCheckout3DSServiceDelegate: AnyObject, Sendable {

    /// Notifies delegate that service is about to fingerprint device.
    @MainActor
    func checkout3DSService(
        _ service: POCheckout3DSService,
        willCreateAuthenticationRequestParametersWith configuration: PO3DS2Configuration
    )

    /// Allows delegate to return customized 3DS service configuration.
    ///
    /// Your implementation could return custom `ThreeDS2ServiceConfiguration` in case you want to
    /// customize underlying 3DS SDK appearance and behavior. Please note that `configParameters`
    /// should remain unchanged.
    @MainActor
    func checkout3DSService(
        _ service: POCheckout3DSService,
        configurationWith parameters: ThreeDS2ServiceConfiguration.ConfigParameters
    ) -> ThreeDS2ServiceConfiguration?

    /// Asks delegate whether service should continue with given warnings. Default implementation
    /// ignores warnings and returns `true`.
    @MainActor
    func checkout3DSService(_ service: POCheckout3DSService, shouldContinueWith warnings: Set<Warning>) async -> Bool

    /// Notifies delegate that service failed to produce device fingerprint.
    @MainActor
    func checkout3DSService(
        _ service: POCheckout3DSService,
        didCreateAuthenticationRequestParameters result: Result<PO3DS2AuthenticationRequestParameters, POFailure>
    )

    /// Notifies delegate that implementation is about to perform 3DS2 challenge.
    @MainActor
    func checkout3DSService(
        _ service: POCheckout3DSService, willPerformChallengeWith parameters: PO3DS2ChallengeParameters
    )

    /// Notifies delegate that service ended processing 3DS2 challenge with either success or failure.
    @MainActor
    func checkout3DSService(
        _ service: POCheckout3DSService, didPerformChallenge result: Result<PO3DS2ChallengeResult, POFailure>
    )

    // MARK: - Deprecations

    /// Notifies delegate that service is about to fingerprint device.
    @available(*, deprecated, renamed: "checkout3DSService(_:willCreateAuthenticationRequestParametersWith:)")
    func willCreateAuthenticationRequest(configuration: PO3DS2Configuration)

    /// Asks implementation to create `ThreeDS2ServiceConfiguration` using `configParameters`. This method
    /// could be used to customize underlying 3DS SDK appearance and behavior.
    @available(*, deprecated, renamed: "checkout3DSService(_:configurationWith:)")
    func configuration(
        with parameters: Checkout3DS.ThreeDS2ServiceConfiguration.ConfigParameters
    ) -> Checkout3DS.ThreeDS2ServiceConfiguration

    /// Asks delegate whether service should continue with given warnings. Default implementation
    /// ignores warnings and completes with `true`.
    @available(*, deprecated, renamed: "checkout3DSService(_:shouldContinueWith:)")
    func shouldContinue(with warnings: Set<Checkout3DS.Warning>, completion: @escaping (Bool) -> Void)

    /// Notifies delegate that service did complete device fingerprinting.
    @available(*, deprecated, renamed: "checkout3DSService(_:didCreateAuthenticationRequestParameters:)")
    func didCreateAuthenticationRequest(result: Result<PO3DS2AuthenticationRequestParameters, POFailure>)

    /// Notifies delegate that implementation is about to handle 3DS2 challenge.
    @available(*, deprecated, renamed: "checkout3DSService(_:willPerformChallengeWith:)")
    func willHandle(challenge: PO3DS2ChallengeParameters)

    /// Notifies delegate that service did end handling 3DS2 challenge with given result.
    @available(*, deprecated, renamed: "checkout3DSService(_:didPerformChallenge:)")
    func didHandle3DS2Challenge(result: Result<Bool, POFailure>)

    /// Asks delegate to handle 3DS redirect. See documentation of `PO3DSService/handle(redirect:completion:)`
    /// for more details.
    @available(*, deprecated, message: "Redirects are handled internally.")
    func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void)
}

/// Provides default implementations to ensure backward compatibility.
extension POCheckout3DSServiceDelegate {

    @MainActor
    public func checkout3DSService(
        _ service: POCheckout3DSService,
        willCreateAuthenticationRequestParametersWith configuration: PO3DS2Configuration
    ) {
        willCreateAuthenticationRequest(configuration: configuration)
    }

    @MainActor
    public func checkout3DSService(
        _ service: POCheckout3DSService,
        configurationWith parameters: ThreeDS2ServiceConfiguration.ConfigParameters
    ) -> ThreeDS2ServiceConfiguration? {
        configuration(with: parameters)
    }

    @MainActor
    public func checkout3DSService(
        _ service: POCheckout3DSService, shouldContinueWith warnings: Set<Warning>
    ) async -> Bool {
        await withCheckedContinuation { continuation in
            shouldContinue(with: warnings) { continuation.resume(returning: $0) }
        }
    }

    @MainActor
    public func checkout3DSService(
        _ service: POCheckout3DSService,
        didCreateAuthenticationRequestParameters result: Result<PO3DS2AuthenticationRequestParameters, POFailure>
    ) {
        didCreateAuthenticationRequest(result: result)
    }

    @MainActor
    public func checkout3DSService(
        _ service: POCheckout3DSService, willPerformChallengeWith parameters: PO3DS2ChallengeParameters
    ) {
        willHandle(challenge: parameters)
    }

    @MainActor
    public func checkout3DSService(
        _ service: POCheckout3DSService, didPerformChallenge result: Result<PO3DS2ChallengeResult, POFailure>
    ) {
        didHandle3DS2Challenge(result: result.map { $0.transactionStatus == "Y" })
    }
}

extension POCheckout3DSServiceDelegate {

    @available(*, deprecated)
    public func willCreateAuthenticationRequest(configuration: PO3DS2Configuration) {
        // Ignored
    }

    @available(*, deprecated)
    public func configuration(
        with parameters: Checkout3DS.ThreeDS2ServiceConfiguration.ConfigParameters
    ) -> Checkout3DS.ThreeDS2ServiceConfiguration {
        ThreeDS2ServiceConfiguration(configParameters: parameters)
    }

    @available(*, deprecated)
    public func didCreateAuthenticationRequest(result: Result<PO3DS2AuthenticationRequestParameters, POFailure>) {
        // Ignored
    }

    @available(*, deprecated)
    public func willHandle(challenge: PO3DS2ChallengeParameters) {
        // Ignored
    }

    @available(*, deprecated)
    public func didHandle3DS2Challenge(result: Result<Bool, POFailure>) {
        // Ignored
    }

    @available(*, deprecated)
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
