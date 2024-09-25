//
//  DefaultCardUpdateInteractorTests.swift
//  ProcessOutUITests
//
//  Created by Andrii Vysotskyi on 14.11.2023.
//

import XCTest
@testable import ProcessOut
@testable import ProcessOutUI

final class DefaultCardUpdateInteractorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        ProcessOut.configure(configuration: .init(projectId: Constants.projectId), force: true)
        cardsService = ProcessOut.shared.cards
    }

    // MARK: - Start

    @MainActor
    func test_start_whenCardInfoIsNotSet_setsStartingState() {
        // Given
        let delegate = CardUpdateDelegateMock()
        let configuration = POCardUpdateConfiguration(cardId: "")
        let sut = createSut(configuration: configuration, delegate: delegate)

        // When
        let expectation = XCTestExpectation()
        delegate.cardInformationFromClosure = { [unowned sut] _ in
            if sut.state == .starting {
                expectation.fulfill()
            }
            return nil
        }
        sut.start()

        // Then
        wait(for: [expectation])
    }

    // MARK: - Scheme Resolve

    @MainActor
    func test_start_whenCardSchemeIsSetInConfiguration_setsStartedStateWithIt() {
        // Given
        let configuration = POCardUpdateConfiguration(cardId: "", cardInformation: .init(scheme: "visa"))
        let sut = createSut(configuration: configuration)

        // When
        sut.start()

        // Then
        guard case .started(let startedState) = sut.state else {
            XCTFail("Unexpected state")
            return
        }
        XCTAssertEqual(startedState.scheme, .visa)
    }

    @MainActor
    func test_start_whenPreferredCardSchemeIsAvailable_setsStartedStateWithIt() {
        // Given
        let configuration = POCardUpdateConfiguration(
            cardId: "", cardInformation: .init(scheme: "visa", preferredScheme: "carte bancaire")
        )
        let sut = createSut(configuration: configuration)

        // When
        sut.start()

        // Then
        guard case .started(let startedState) = sut.state else {
            XCTFail("Unexpected state")
            return
        }
        XCTAssertEqual(startedState.scheme, .visa)
        XCTAssertEqual(startedState.preferredScheme, .carteBancaire)
    }

    @MainActor
    func test_start_whenCardSchemeIsNotSetAndIinIsSet_attemptsToResolve() {
        // Given
        let configuration = POCardUpdateConfiguration(cardId: "", cardInformation: .init(iin: "424242"))
        let sut = createSut(configuration: configuration)

        // When
        sut.start()

        // Then
        let expectation = XCTestExpectation()
        sut.didChange = { [weak sut] in
            if case .started(let startedState) = sut?.state, startedState.scheme == .visa {
                expectation.fulfill()
            }
        }
        wait(for: [expectation])
    }

    @MainActor
    func test_start_whenCardSchemeIsNotSetAndMaskedNumberIsSet_attemptsToResolve() {
        // Given
        let configuration = POCardUpdateConfiguration(
            cardId: "", cardInformation: .init(maskedNumber: "4242 42** **42")
        )
        let sut = createSut(configuration: configuration)

        // When
        sut.start()

        // Then
        let expectation = XCTestExpectation()
        sut.didChange = { [weak sut] in
            if case .started(let startedState) = sut?.state, startedState.scheme == .visa {
                expectation.fulfill()
            }
        }
        wait(for: [expectation])
    }

    // MARK: - Cancel

    @MainActor
    func test_cancel_whenStarted() {
        // Given
        let configuration = POCardUpdateConfiguration(cardId: "", cardInformation: .init(scheme: "visa"))
        let sut = createSut(configuration: configuration)
        sut.start()

        // When
        sut.cancel()

        // Then
        XCTAssertEqual(sut.state, .completed)
    }

    // MARK: - Update CVC

    @MainActor
    func test_updateCvc_whenStarting_isIgnored() {
        // Given
        let configuration = POCardUpdateConfiguration(cardId: "")
        let sut = createSut(configuration: configuration)
        sut.start()
        let oldState = sut.state

        // When
        sut.update(cvc: "123")

        // Then
        XCTAssertEqual(sut.state, oldState)
    }

    @MainActor
    func test_updateCvc_whenStarted_updatesState() {
        // Given
        let configuration = POCardUpdateConfiguration(cardId: "", cardInformation: .init(scheme: "visa"))
        let sut = createSut(configuration: configuration)
        sut.start()

        // When
        sut.update(cvc: "1 23 45")

        // Then
        guard case .started(let startedState) = sut.state else {
            return
        }
        XCTAssertEqual(startedState.cvc, "123")
    }

    // MARK: - Submit

    @MainActor
    func test_submit_whenCvcIsNotSet_causesError() {
        // Given
        let configuration = POCardUpdateConfiguration(cardId: "", cardInformation: .init(scheme: "visa"))
        let sut = createSut(configuration: configuration)
        sut.start()

        // When
        sut.submit()

        // Then
        let expectation = XCTestExpectation()
        sut.didChange = { [weak sut] in
            if case .started(let startedState) = sut?.state, startedState.recentErrorMessage != nil {
                expectation.fulfill()
            }
        }
        wait(for: [expectation])
    }

    @MainActor
    func test_submit_whenValidCvcIsSet_completes() {
        // Given
        let configuration = POCardUpdateConfiguration(
            cardId: "card_ZbHkl2Uh3Udafx2cbb2uN4pP2evwHPyf", cardInformation: .init(scheme: "visa")
        )
        let sut = createSut(configuration: configuration)
        sut.start()
        sut.update(cvc: "123")

        // When
        sut.submit()

        // Then
        let expectation = XCTestExpectation()
        sut.didChange = { [weak sut] in
            if case .completed = sut?.state {
                expectation.fulfill()
            }
        }
        wait(for: [expectation])
    }

    // MARK: - Private Properties

    private var cardsService: POCardsService!

    // MARK: - Private Methods

    @MainActor
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
