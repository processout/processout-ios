//
//  POCardUpdateDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

import ProcessOut

/// Card update module delegate definition.
public protocol POCardUpdateDelegate: AnyObject {

    /// Invoked when module emits event.
    func cardUpdateDidEmitEvent(_ event: POCardUpdateEvent)

    /// Asks delegate to resolve card information based on card id.
    func cardInformation(cardId: String) async -> POCardUpdateInformation?

    /// Asks delegate whether user should be allowed to continue after failure or module should complete.
    /// Default implementation returns `true`.
    func shouldContinueUpdate(after failure: POFailure) -> Bool
}

extension POCardUpdateDelegate {

    func cardUpdateDidEmitEvent(_ event: POCardUpdateEvent) {
        // Ignored
    }

    func cardInformation(cardId: String) async -> POCardUpdateInformation? {
        nil
    }

    func shouldContinueUpdate(after failure: POFailure) -> Bool {
        true
    }
}
