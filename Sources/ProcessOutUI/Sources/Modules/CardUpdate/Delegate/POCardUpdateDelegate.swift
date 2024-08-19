//
//  POCardUpdateDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

import ProcessOut

/// Card update module delegate definition.
public protocol POCardUpdateDelegate: AnyObject, Sendable {

    /// Asks delegate to resolve card information based on card id.
    func cardUpdate(informationFor cardId: String) async -> POCardUpdateInformation?

    /// Invoked when module emits event.
    @MainActor
    func cardUpdate(didEmitEvent event: POCardUpdateEvent)

    /// Asks delegate whether user should be allowed to continue after failure or module should complete.
    /// Default implementation returns `true`.
    @MainActor
    func cardUpdate(shouldContinueAfter failure: POFailure) -> Bool
}

extension POCardUpdateDelegate {

    public func cardUpdate(informationFor cardId: String) async -> POCardUpdateInformation? {
        nil
    }

    @MainActor
    public func cardUpdate(didEmitEvent event: POCardUpdateEvent) {
        // Ignored
    }

    @MainActor
    public func cardUpdate(shouldContinueAfter failure: POFailure) -> Bool {
        true
    }
}
