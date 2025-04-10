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

    /// Allows delegate to additionally process tokenized card before ending module's lifecycle. For example
    /// it is possible to authorize an invoice or assign customer token. Default implementation does nothing.
    ///
    /// - NOTE: When possible please prefer throwing `POFailure` instead of other error types.
    @available(*, deprecated, message: "Implement cardTokenization(didTokenizeCard:save:) method instead.")
    @MainActor
    func processTokenizedCard(card: POCard) async throws

    /// Allows to choose preferred scheme that will be selected by default based on issuer information. Default
    /// implementation returns primary scheme.
    @MainActor
    func preferredScheme(issuerInformation: POCardIssuerInformation) -> String?

    /// Asks delegate whether user should be allowed to continue after failure or module should complete.
    /// Default implementation returns `true`.
    @MainActor
    func shouldContinueTokenization(after failure: POFailure) -> Bool

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
    public func cardTokenization(didTokenizeCard card: POCard, shouldSaveCard: Bool) async throws {
        // Ignored
    }

    @available(*, deprecated, message: "Implement cardTokenization(didTokenizeCard:save:) method instead.")
    @MainActor
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

    @MainActor
    public func cardTokenization(willScanCardWith configuration: POCardScannerConfiguration) -> POCardScannerDelegate? {
        nil
    }
}
