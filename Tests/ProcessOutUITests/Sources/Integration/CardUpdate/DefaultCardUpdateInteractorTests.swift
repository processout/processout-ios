//
//  DefaultCardUpdateInteractorTests.swift
//  ProcessOutUITests
//
//  Created by Andrii Vysotskyi on 14.11.2023.
//

import XCTest
@testable import ProcessOut
@testable import ProcessOutUI

@MainActor
final class DefaultCardUpdateInteractorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let configuration = ProcessOutConfiguration.production(projectId: Constants.projectId)
        cardsService = ProcessOut(configuration: configuration).cards
    }

    func test_start_setsStartingState() {
        // Given
        let configuration = POCardUpdateConfiguration(cardId: "")
        let sut = createSut(configuration: configuration)

        // When
        sut.start()

        // Then
        XCTAssertEqual(sut.state, .starting)
    }

    func test_start_whenCardInformationIsAvailableInConfiguration_setsStartedState() {
        // Given
        let configuration = POCardUpdateConfiguration(
            cardId: "", cardInformation: .init(scheme: "visa")
        )
        let sut = createSut(configuration: configuration)

        // When
        sut.start()

        // Then
        if case .started = sut.state {
            return
        }
        XCTFail("Unexpected state")
    }

    // MARK: - Private Properties

    private var cardsService: POCardsService!

    // MARK: - Private Methods

    private func createSut(
        configuration: POCardUpdateConfiguration, delegate: POCardUpdateDelegate? = nil
    ) -> any CardUpdateInteractor {
        let interactor = DefaultCardUpdateInteractor(
            cardsService: cardsService,
            logger: .stub,
            configuration: configuration,
            delegate: delegate,
            completion: { _ in }
        )
        return interactor
    }
}
