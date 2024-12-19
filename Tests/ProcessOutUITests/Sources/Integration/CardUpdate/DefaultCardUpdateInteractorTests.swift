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
        await confirmation { confirm in
            sut.didChange = {
                if case .starting = sut.state {
                    confirm()
                }
            }
            sut.start()
            try? await Task.sleep(for: .seconds(1))
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
        try? await Task.sleep(for: .seconds(1))

        // Then
        guard case .started(let startedState) = sut.state else {
            Issue.record("Unexpected state.")
            return
        }
        #expect(startedState.scheme == .visa)
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
        try? await Task.sleep(for: .seconds(1))

        // Then
        guard case .started(let startedState) = sut.state else {
            Issue.record("Unexpected state.")
            return
        }
        #expect(startedState.scheme == .visa && startedState.preferredScheme == .carteBancaire)
    }

    @Test
    func start_whenCardSchemeIsNotSetAndIinIsSet_attemptsToResolve() async {
        // Given
        let configuration = POCardUpdateConfiguration(cardId: "", cardInformation: .init(iin: "424242"))
        let sut = createSut(configuration: configuration)

        // When
        sut.start()

        // Then
        await confirmation { confirm in
            sut.didChange = { [weak sut] in
                if case .started(let startedState) = sut?.state, startedState.scheme == .visa {
                    confirm()
                }
            }
            try? await Task.sleep(for: .seconds(3))
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

        // Then
        await confirmation { confirm in
            sut.didChange = { [weak sut] in
                if case .started(let startedState) = sut?.state, startedState.scheme == .visa {
                    confirm()
                }
            }
            try? await Task.sleep(for: .seconds(1))
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
        try? await Task.sleep(for: .seconds(1))

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
        try? await Task.sleep(for: .seconds(1))
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
        let configuration = POCardUpdateConfiguration(cardId: "", cardInformation: .init(scheme: "visa"))
        let sut = createSut(configuration: configuration)

        // When
        sut.start()
        try? await Task.sleep(for: .seconds(1))
        sut.submit()

        // Then
        await confirmation { confirm in
            sut.didChange = { [weak sut] in
                if case .started(let startedState) = sut?.state, startedState.recentErrorMessage != nil {
                    confirm()
                }
            }
            try? await Task.sleep(for: .seconds(3))
        }
    }

    @Test
    func submit_whenValidCvcIsSet_completes() async {
        // Given
        let configuration = POCardUpdateConfiguration(
            cardId: "card_ZbHkl2Uh3Udafx2cbb2uN4pP2evwHPyf", cardInformation: .init(scheme: "visa")
        )
        let sut = createSut(configuration: configuration)

        // When
        sut.start()
        try? await Task.sleep(for: .seconds(1))
        sut.update(cvc: "123")
        sut.submit()

        // Then
        await confirmation { confirm in
            sut.didChange = { [weak sut] in
                if case .completed = sut?.state {
                    confirm()
                }
            }
            try? await Task.sleep(for: .seconds(3))
        }
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
