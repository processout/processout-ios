//
//  POCardTokenizationDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 09.08.2023.
//

import ProcessOut

/// Card tokenization module delegate definition.
public protocol POCardTokenizationDelegate: AnyObject {

    /// Invoked when module emits event.
    func cardTokenization(coordinator: POCardTokenizationCoordinator, didEmitEvent event: POCardTokenizationEvent)

    /// Allows delegate to additionally process tokenized card before ending module's lifecycle. For example
    /// it is possible to authorize an invoice or assign customer token.
    /// Default implementation does nothing.
    ///
    /// - NOTE: When possible please prefer throwing `POFailure` instead of other error types.
    func cardTokenization(coordinator: POCardTokenizationCoordinator, didTokenizeCard card: POCard) async throws

    /// Allows to choose preferred scheme that will be selected by default based on issuer information. Default
    /// implementation returns primary scheme.
    func cardTokenization(
        coordinator: POCardTokenizationCoordinator,
        preferredSchemeFor issuerInformation: POCardIssuerInformation
    ) -> String?

    /// Asks delegate whether user should be allowed to continue after failure or module should complete.
    /// Default implementation returns `true`.
    func cardTokenization(coordinator: POCardTokenizationCoordinator, shouldContinueAfter failure: POFailure) -> Bool

    /// Notifies delegate about state change.
    func cardTokenization(coordinator: POCardTokenizationCoordinator, didChangeState state: POCardTokenizationState)
}

extension POCardTokenizationDelegate {

    public func cardTokenization(
        coordinator: POCardTokenizationCoordinator, didEmitEvent event: POCardTokenizationEvent
    ) {
        // Ignroed
    }

    public func cardTokenization(
        coordinator: POCardTokenizationCoordinator, didTokenizeCard card: POCard
    ) async throws {
        // Ignored
    }

    public func cardTokenization(
        coordinator: POCardTokenizationCoordinator,
        preferredSchemeFor issuerInformation: POCardIssuerInformation
    ) -> String? {
        issuerInformation.scheme
    }

    public func cardTokenization(
        coordinator: POCardTokenizationCoordinator, shouldContinueAfter failure: POFailure
    ) -> Bool {
        true
    }

    public func cardTokenization(
        coordinator: POCardTokenizationCoordinator, didChangeState state: POCardTokenizationState
    ) {
        // Ignored
    }
}