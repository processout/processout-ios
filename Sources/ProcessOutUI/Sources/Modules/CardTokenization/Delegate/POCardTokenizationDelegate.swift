//
//  POCardTokenizationDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 09.08.2023.
//

import ProcessOut

/// Card tokenization module delegate definition.
public protocol POCardTokenizationDelegate: AnyObject, Sendable {

    /// Invoked when module emits event.
    @MainActor
    func cardTokenizationDidEmitEvent(_ event: POCardTokenizationEvent)

    /// Allows delegate to additionally process tokenized card before ending module's lifecycle. For example
    /// it is possible to authorize an invoice or assign customer token.
    /// Default implementation does nothing.
    ///
    /// - NOTE: When possible please prefer throwing `POFailure` instead of other error types.
    func processTokenizedCard(card: POCard) async throws

    /// Allows to choose preferred scheme that will be selected by default based on issuer information. Default
    /// implementation returns primary scheme.
    @MainActor
    func preferredScheme(issuerInformation: POCardIssuerInformation) -> String?

    /// Asks delegate whether user should be allowed to continue after failure or module should complete.
    /// Default implementation returns `true`.
    @MainActor
    func shouldContinueTokenization(after failure: POFailure) -> Bool
}

extension POCardTokenizationDelegate {

    @MainActor
    public func cardTokenizationDidEmitEvent(_ event: POCardTokenizationEvent) {
        // Ignored
    }

    public func processTokenizedCard(card: POCard) async throws {
        // Ignored
    }

    @MainActor
    public func preferredScheme(issuerInformation: POCardIssuerInformation) -> String? {
        issuerInformation.scheme
    }

    @MainActor
    public func shouldContinueTokenization(after failure: POFailure) -> Bool {
        true
    }
}
