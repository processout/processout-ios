//
//  CardUpdateDelegateMock.swift
//  ProcessOutUITests
//
//  Created by Andrii Vysotskyi on 14.11.2023.
//

import ProcessOut
@testable import ProcessOutUI

final class CardUpdateDelegateMock: POCardUpdateDelegate {

    var cardUpdateDidEmitEventFromClosure: ((POCardUpdateEvent) -> Void)!
    var cardInformationFromClosure: ((String) -> POCardUpdateInformation?)!
    var shouldContinueUpdateFromClosure: ((POFailure) -> Bool)!

    // MARK: - PO3DSService

    func cardUpdateDidEmitEvent(_ event: POCardUpdateEvent) {
        cardUpdateDidEmitEventFromClosure(event)
    }

    func cardInformation(cardId: String) async -> POCardUpdateInformation? {
        cardInformationFromClosure(cardId)
    }

    func shouldContinueUpdate(after failure: POFailure) -> Bool {
        shouldContinueUpdateFromClosure(failure)
    }
}
