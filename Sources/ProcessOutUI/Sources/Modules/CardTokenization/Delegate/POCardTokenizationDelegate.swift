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
    func cardTokenizationDidEmitEvent(_ event: POCardTokenizationEvent)

    /// Allows delegate to additionally process tokenized card before ending module's lifecycle. For example
    /// it is possible to authorize an invoice or assign customer token. Default implementation does nothing.
    ///
    /// - Parameters:
    ///   - card: Tokenized card instance.
    ///   - shouldSaveCard: A Boolean value indicating whether the user has requested card to be saved.
    ///
    /// - NOTE: When possible please prefer throwing `POFailure` instead of other error types.
    func cardTokenization(didTokenizeCard card: POCard, shouldSaveCard: Bool) async throws

    /// Allows delegate to additionally process tokenized card before ending module's lifecycle. For example
    /// it is possible to authorize an invoice or assign customer token. Default implementation does nothing.
    ///
    /// - NOTE: When possible please prefer throwing `POFailure` instead of other error types.
    @available(*, deprecated, message: "Implement cardTokenization(didTokenizeCard:save:) method instead.")
    func processTokenizedCard(card: POCard) async throws

    /// Allows to choose preferred scheme that will be selected by default based on issuer information. Default
    /// implementation returns primary scheme.
    func preferredScheme(issuerInformation: POCardIssuerInformation) -> String?

    /// Asks delegate whether user should be allowed to continue after failure or module should complete.
    /// Default implementation returns `true`.
    func shouldContinueTokenization(after failure: POFailure) -> Bool
}

extension POCardTokenizationDelegate {

    public func cardTokenizationDidEmitEvent(_ event: POCardTokenizationEvent) {
        // Ignored
    }

    public func cardTokenization(didTokenizeCard card: POCard, shouldSaveCard: Bool) async throws {
        // Ignored
    }

    @available(*, deprecated, message: "Implement cardTokenization(didTokenizeCard:save:) method instead.")
    public func processTokenizedCard(card: POCard) async throws {
        // Ignored
    }

    public func preferredScheme(issuerInformation: POCardIssuerInformation) -> String? {
        issuerInformation.scheme
    }

    public func shouldContinueTokenization(after failure: POFailure) -> Bool {
        true
    }
}
