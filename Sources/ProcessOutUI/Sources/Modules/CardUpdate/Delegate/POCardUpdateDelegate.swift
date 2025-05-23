//
//  POCardUpdateDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

import ProcessOut

/// Card update module delegate definition.
@preconcurrency
public protocol POCardUpdateDelegate: AnyObject, Sendable {

    /// Invoked when module emits event.
    @MainActor
    func cardUpdateDidEmitEvent(_ event: POCardUpdateEvent)

    /// Asks delegate to resolve card information based on card id.
    @MainActor
    func cardInformation(cardId: String) async -> POCardUpdateInformation?

    /// Asks delegate whether user should be allowed to continue after failure or module should complete.
    /// Default implementation returns `true`.
    @MainActor
    func shouldContinueUpdate(after failure: POFailure) -> Bool
}

extension POCardUpdateDelegate {

    @MainActor
    public func cardUpdateDidEmitEvent(_ event: POCardUpdateEvent) {
        // Ignored
    }

    @MainActor
    public func cardInformation(cardId: String) async -> POCardUpdateInformation? {
        nil
    }

    @MainActor
    public func shouldContinueUpdate(after failure: POFailure) -> Bool {
        true
    }
}
