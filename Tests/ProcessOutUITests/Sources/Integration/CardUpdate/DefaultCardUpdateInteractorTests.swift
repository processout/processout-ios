//
//  DefaultCardUpdateInteractorTests.swift
//  ProcessOutUITests
//
//  Created by Andrii Vysotskyi on 14.11.2023.
//

import Testing
@testable import ProcessOut
@testable import ProcessOutUI

@MainActor
struct DefaultCardUpdateInteractorTests {

    init() {
        let processOut = ProcessOut(configuration: .init(projectId: Constants.projectId))
        cardsService = processOut.cards
    }

    // MARK: - Start

    @Test
    func start_whenCardInfoIsNotSet_setsStartingState() async {
        // Given
        let configuration = POCardUpdateConfiguration(cardId: "")
        let sut = createSut(configuration: configuration)

        // When
        sut.start()

        // Then
        switch sut.state {
        case .starting:
            break
        default:
            Issue.record("Unexpected state.")
        }
    }

    // MARK: - Scheme Resolve

    @Test
    func start_whenCardSchemeIsSetInConfiguration_setsStartedStateWithIt() async {
        // Given
        let configuration = POCardUpdateConfiguration(cardId: "", cardInformation: .init(scheme: "visa"))
        let sut = createSut(configuration: configuration)

        // When
        sut.start()
        if case .starting(let currentState) = sut.state {
            _ = await currentState.task.result
        }

        // Then
        switch sut.state {
        case .started(let currentState):
            #expect(currentState.scheme == .visa)
        default:
            Issue.record("Unexpected state.")
        }
    }

    @Test
    func start_whenPreferredCardSchemeIsAvailable_setsStartedStateWithIt() async {
        // Given
        let configuration = POCardUpdateConfiguration(
            cardId: "", cardInformation: .init(scheme: "visa", preferredScheme: "carte bancaire")
        )
        let sut = createSut(configuration: configuration)

        // When
        sut.start()
        if case .starting(let currentState) = sut.state {
            _ = await currentState.task.result
        }

        // Then
        switch sut.state {
        case .started(let currentState):
            #expect(currentState.scheme == .visa && currentState.preferredScheme == .carteBancaire)
        default:
            Issue.record("Unexpected state.")
        }
    }

    @Test
    func start_whenCardSchemeIsNotSetAndIinIsSet_attemptsToResolve() async {
        // Given
        let configuration = POCardUpdateConfiguration(cardId: "", cardInformation: .init(iin: "424242"))
        let sut = createSut(configuration: configuration)

        // When
        sut.start()
        if case .starting(let currentState) = sut.state {
            _ = await currentState.task.result
        }

        // Then
        switch sut.state {
        case .started(let currentState):
            #expect(currentState.scheme == .visa)
        default:
            Issue.record("Unexpected state.")
        }
    }

    @Test
    func start_whenCardSchemeIsNotSetAndMaskedNumberIsSet_attemptsToResolve() async {
        // Given
        let configuration = POCardUpdateConfiguration(
            cardId: "", cardInformation: .init(maskedNumber: "4242 42** **42")
        )
        let sut = createSut(configuration: configuration)

        // When
        sut.start()
        if case .starting(let currentState) = sut.state {
            _ = await currentState.task.result
        }

        // Then
        switch sut.state {
        case .started(let currentState):
            #expect(currentState.scheme == .visa)
        default:
            Issue.record("Unexpected state.")
        }
    }

    // MARK: - Cancel

    @Test
    func cancel_whenStarted() async {
        // Given
        let configuration = POCardUpdateConfiguration(cardId: "", cardInformation: .init(scheme: "visa"))
        let sut = createSut(configuration: configuration)

        // When
        sut.start()
        if case .starting(let currentState) = sut.state {
            _ = await currentState.task.result
        }

        // Then
        sut.cancel()
        if case .completed = sut.state { } else {
            Issue.record("Expected completed state.")
        }
    }

    // MARK: - Update CVC

    @Test
    func updateCvc_whenStarting_isIgnored() {
        // Given
        let configuration = POCardUpdateConfiguration(cardId: "")
        let sut = createSut(configuration: configuration)
        sut.start()

        // When
        sut.update(cvc: "123")

        // Then
        if case .starting = sut.state { } else {
            Issue.record("Expected starting state.")
        }
    }

    @Test
    func updateCvc_whenStarted_updatesState() async {
        // Given
        let configuration = POCardUpdateConfiguration(cardId: "", cardInformation: .init(scheme: "visa"))
        let sut = createSut(configuration: configuration)

        // When
        sut.start()
        if case .starting(let currentState) = sut.state {
            _ = await currentState.task.result
        }
        sut.update(cvc: "1 23 45")

        // Then
        guard case .started(let startedState) = sut.state else {
            Issue.record("Unexpected state.")
            return
        }
        #expect(startedState.cvc == "123")
    }

    // MARK: - Submit

    @Test
    func submit_whenCvcIsNotSet_causesError() async {
        // Given
        let configuration = POCardUpdateConfiguration(
            cardId: Constants.testCardId, cardInformation: .init(scheme: "visa")
        )
        let sut = createSut(configuration: configuration)

        // When
        sut.start()
        if case .starting(let currentState) = sut.state {
            _ = await currentState.task.result
        }
        sut.submit()
        if case .updating(let currentState) = sut.state {
            _ = await currentState.task.result
        }

        // Then
        switch sut.state {
        case .started(let currentState):
            #expect(currentState.recentErrorMessage != nil)
        default:
            Issue.record("Unexpected state.")
        }
    }

    @Test
    func submit_whenValidCvcIsSet_completes() async {
        // Given
        let configuration = POCardUpdateConfiguration(
            cardId: Constants.testCardId, cardInformation: .init(scheme: "visa")
        )
        let sut = createSut(configuration: configuration)

        // When
        sut.start()
        if case .starting(let currentState) = sut.state {
            _ = await currentState.task.result
        }
        sut.update(cvc: "123")
        sut.submit()
        if case .updating(let currentState) = sut.state {
            _ = await currentState.task.result
        }

        // Then
        switch sut.state {
        case .completed:
            break
        default:
            Issue.record("Unexpected state.")
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let testCardId = "card_ZbHkl2Uh3Udafx2cbb2uN4pP2evwHPyf"
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
