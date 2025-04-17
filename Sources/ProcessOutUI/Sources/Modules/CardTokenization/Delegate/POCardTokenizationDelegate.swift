//
//  POCardTokenizationDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 09.08.2023.
//

import ProcessOut

/// Card tokenization module delegate definition.
@preconcurrency
public protocol POCardTokenizationDelegate: AnyObject, Sendable {

    /// Invoked when module emits event.
    @MainActor
    func cardTokenizationDidEmitEvent(_ event: POCardTokenizationEvent)

    /// Allows delegate to additionally process tokenized card before ending module's lifecycle. For example
    /// it is possible to authorize an invoice or assign customer token. Default implementation does nothing.
    ///
    /// - Parameters:
    ///   - card: Tokenized card instance.
    ///   - shouldSaveCard: A Boolean value indicating whether the user has requested card to be saved.
    ///
    /// - NOTE: When possible please prefer throwing `POFailure` instead of other error types.
    @MainActor
    func cardTokenization(didTokenizeCard card: POCard, shouldSaveCard: Bool) async throws

    /// Asks the delegate to evaluate whether a card is eligible for tokenization based on its issuer information.
    @MainActor
    func cardTokenization(
        evaluateEligibilityWith request: POCardTokenizationEligibilityRequest
    ) async -> POCardTokenizationEligibilityEvaluation

    /// Allows to choose preferred scheme that will be selected by default based on issuer information. Default
    /// implementation uses primary scheme.
    @MainActor
    func cardTokenization(preferredSchemeWith issuerInformation: POCardIssuerInformation) -> POCardScheme?

    /// Asks delegate whether user should be allowed to continue after failure or module should complete.
    /// Default implementation returns `true`.
    @MainActor
    func shouldContinueTokenization(after failure: POFailure) -> Bool

    // MARK: - Deprecations

    /// Allows to choose preferred scheme that will be selected by default based on issuer information. Default
    /// implementation uses primary scheme.
    @available(*, deprecated, message: "Implement cardTokenization(preferredSchemeWith:) method instead.")
    @MainActor
    func preferredScheme(issuerInformation: POCardIssuerInformation) -> String?

    /// Allows delegate to additionally process tokenized card before ending module's lifecycle. For example
    /// it is possible to authorize an invoice or assign customer token. Default implementation does nothing.
    ///
    /// - NOTE: When possible please prefer throwing `POFailure` instead of other error types.
    @available(*, deprecated, message: "Implement cardTokenization(didTokenizeCard:save:) method instead.")
    @MainActor
    func processTokenizedCard(card: POCard) async throws

    // MARK: - Card Scanning

    /// Notifies the delegate before a card scanning session begins and allows providing
    /// a delegate to handle scanning events.
    @MainActor
    func cardTokenization(willScanCardWith configuration: POCardScannerConfiguration) -> POCardScannerDelegate?
}

extension POCardTokenizationDelegate {

    @MainActor
    public func cardTokenizationDidEmitEvent(_ event: POCardTokenizationEvent) {
        // Ignored
    }

    @MainActor
    public func cardTokenization(preferredSchemeWith issuerInformation: POCardIssuerInformation) -> POCardScheme? {
        preferredScheme(issuerInformation: issuerInformation).map(POCardScheme.init)
    }

    @MainActor
    public func cardTokenization(didTokenizeCard card: POCard, shouldSaveCard: Bool) async throws {
        try await processTokenizedCard(card: card)
    }

    @available(*, deprecated, message: "Implement cardTokenization(didTokenizeCard:save:) method instead.")
    @MainActor
    public func processTokenizedCard(card: POCard) async throws {
        // Ignored
    }

    @MainActor
    public func cardTokenization(
        evaluateEligibilityWith request: POCardTokenizationEligibilityRequest
    ) async -> POCardTokenizationEligibilityEvaluation {
        .eligible()
    }

    @MainActor
    public func preferredScheme(issuerInformation: POCardIssuerInformation) -> String? {
        issuerInformation.scheme
    }

    @MainActor
    public func shouldContinueTokenization(after failure: POFailure) -> Bool {
        true
    }

    @MainActor
    public func cardTokenization(willScanCardWith configuration: POCardScannerConfiguration) -> POCardScannerDelegate? {
        nil
    }
}
