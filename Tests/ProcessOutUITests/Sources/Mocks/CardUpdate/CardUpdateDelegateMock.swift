//
//  CardUpdateDelegateMock.swift
//  ProcessOutUITests
//
//  Created by Andrii Vysotskyi on 14.11.2023.
//

@_spi(PO) import ProcessOut
@testable import ProcessOutUI

final class CardUpdateDelegateMock: POCardUpdateDelegate, Sendable {

    var cardUpdateDidEmitEventFromClosure: ((POCardUpdateEvent) -> Void)? {
        get { lock.withLock { _cardUpdateDidEmitEventFromClosure } }
        set { lock.withLock { _cardUpdateDidEmitEventFromClosure = newValue } }
    }

    var cardInformationFromClosure: ((String) -> POCardUpdateInformation?)? {
        get { lock.withLock { _cardInformationFromClosure } }
        set { lock.withLock { _cardInformationFromClosure = newValue } }
    }

    var shouldContinueUpdateFromClosure: ((POFailure) -> Bool)? {
        get { lock.withLock { _shouldContinueUpdateFromClosure } }
        set { lock.withLock { _shouldContinueUpdateFromClosure = newValue } }
    }

    // MARK: - POCardUpdateDelegate

    func cardUpdate(didEmitEvent event: POCardUpdateEvent) {
        cardUpdateDidEmitEventFromClosure?(event)
    }

    func cardUpdate(informationFor cardId: String) async -> POCardUpdateInformation? {
        cardInformationFromClosure?(cardId)
    }

    func cardUpdate(shouldContinueAfter failure: POFailure) -> Bool {
        shouldContinueUpdateFromClosure?(failure) ?? false
    }

    // MARK: - Private Properties

    private let lock = POUnfairlyLocked()

    private nonisolated(unsafe) var _cardUpdateDidEmitEventFromClosure: ((POCardUpdateEvent) -> Void)?
    private nonisolated(unsafe) var _cardInformationFromClosure: ((String) -> POCardUpdateInformation?)?
    private nonisolated(unsafe) var _shouldContinueUpdateFromClosure: ((POFailure) -> Bool)?
}
