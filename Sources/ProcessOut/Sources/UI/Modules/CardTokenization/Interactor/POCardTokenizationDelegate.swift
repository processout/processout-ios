//
//  POCardTokenizationDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 09.08.2023.
//

/// Card tokenization module delegate definition.
@_spi(PO)
public protocol POCardTokenizationDelegate: AnyObject {

    /// Invoked when module emits event.
    func cardTokenizationDidEmitEvent(_ event: POCardTokenizationEvent)

    /// Allows delegate to additionally process tokenized card before ending module's lifecycle. For example
    /// it is possible to authorize an invoice or assign customer token.
    /// Default implementation immediately calls completion.
    func processTokenizedCard(card: POCard, completion: (Result<POCardTokenizationProcessAction?, Error>) -> Void)

    /// Allows to choose preferred scheme that will be selected by default based on issuer information. Default
    /// implementation returns primary scheme.
    func preferredScheme(issuerInformation: POCardIssuerInformation) -> String?

    /// Asks delegate whether user should be allowed to continue after failure or module should complete.
    /// Default implementation returns `true`.
    func shouldContinueTokenization(after failure: POFailure) -> Bool
}

extension POCardTokenizationDelegate {

    public func cardTokenizationDidEmitEvent(_ event: POCardTokenizationEvent) {
        // Ignroed
    }

    // swiftlint:disable:next line_length
    public func processTokenizedCard(card: POCard, completion: (Result<POCardTokenizationProcessAction?, Error>) -> Void) {
        completion(.success(nil))
    }

    public func preferredScheme(issuerInformation: POCardIssuerInformation) -> String? {
        issuerInformation.scheme
    }

    public func shouldContinueTokenization(after failure: POFailure) -> Bool {
        true
    }
}
