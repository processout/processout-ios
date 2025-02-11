//
//  DefaultCardUpdateInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

@_spi(PO) import ProcessOut

final class DefaultCardUpdateInteractor: BaseInteractor<CardUpdateInteractorState>, CardUpdateInteractor {

    init(
        cardsService: POCardsService,
        logger: POLogger,
        configuration: POCardUpdateConfiguration,
        delegate: POCardUpdateDelegate?,
        completion: @escaping (Result<POCard, POFailure>) -> Void
    ) {
        self.cardsService = cardsService
        self.logger = logger
        self.configuration = configuration
        self.delegate = delegate
        self.completion = completion
        super.init(state: .idle)
    }

    // MARK: - CardUpdateInteractor

    override func start() {
        guard case .idle = state else {
            return
        }
        logger.debug("Will start card update")
        delegate?.cardUpdateDidEmitEvent(.willStart)
        let task = Task { @MainActor in
            logger.debug("Did start card update")
            var cardInfo = configuration.cardInformation
            if cardInfo == nil {
                cardInfo = await delegate?.cardInformation(cardId: configuration.cardId)
            }
            let issuerInformation = await self.issuerInformation(cardInfo: cardInfo)
            setStartedState(cardInfo: cardInfo, issuerInformation: issuerInformation)
        }
        let startingState = State.Starting(task: task)
        state = .starting(startingState)
    }

    func update(cvc: String) {
        guard case .started(var startedState) = state else {
            return
        }
        logger.debug("Will change CVC to '\(cvc)'")
        let formatted = startedState.formatter.string(for: cvc) ?? ""
        guard startedState.cvc != formatted else {
            logger.debug("Ignoring same CVC value \(formatted)")
            return
        }
        startedState.areParametersValid = true
        startedState.recentErrorMessage = nil
        startedState.cvc = formatted
        state = .started(startedState)
        delegate?.cardUpdateDidEmitEvent(.parametersChanged)
    }

    func setPreferredScheme(_ scheme: POCardScheme) {
        guard case .started(var startedState) = state, configuration.isSchemeSelectionAllowed else {
            return
        }
        let supportedSchemes = [startedState.scheme, startedState.coScheme].compactMap { $0 }
        logger.debug("Will change card scheme to \(scheme)")
        guard supportedSchemes.contains(scheme) else {
            logger.info("Unable to select unknown '\(scheme)' scheme, supported values: \(supportedSchemes)")
            return
        }
        startedState.preferredScheme = scheme
        state = .started(startedState)
        delegate?.cardUpdateDidEmitEvent(.parametersChanged)
    }

    func submit() {
        guard case .started(let currentState) = state else {
            logger.debug("Ignoring submission attempt from unsupported state: \(state).")
            return
        }
        guard currentState.areParametersValid else {
            logger.debug("Ignoring attempt to submit invalid parameters.")
            return
        }
        logger.debug("Will submit card information.")
        delegate?.cardUpdateDidEmitEvent(.willUpdateCard)
        let task = Task { @MainActor in
            do {
                let request = POCardUpdateRequest(
                    cardId: configuration.cardId,
                    cvc: currentState.cvc,
                    preferredScheme: currentState.preferredScheme?.rawValue
                )
                setCompletedState(card: try await cardsService.updateCard(request: request))
            } catch {
                attemptRecoverUpdateError(error)
            }
        }
        state = .updating(State.Updating(snapshot: currentState, task: task))
    }

    override func cancel() {
        switch state {
        case .starting(let currentState):
            currentState.task.cancel()
        case .updating(let currentState):
            currentState.task.cancel()
        default:
            break // Ignored
        }
        setFailureState(failure: POFailure(message: "Card update has been canceled.", code: .Mobile.cancelled))
    }

    // MARK: - Private Properties

    private let cardsService: POCardsService
    private let logger: POLogger
    private let configuration: POCardUpdateConfiguration
    private let completion: (Result<POCard, POFailure>) -> Void

    private weak var delegate: POCardUpdateDelegate?

    // MARK: - Started State

    private func setStartedState(cardInfo: POCardUpdateInformation?, issuerInformation: POCardIssuerInformation?) {
        switch state {
        case .idle, .starting:
            break
        default:
            logger.debug("Ignoring attempt to set started state from unsupported state: \(state)")
            return
        }
        let formatter = CardSecurityCodeFormatter()
        formatter.scheme = issuerInformation?.$scheme.typed
        let startedState = State.Started(
            cardNumber: cardInfo?.maskedNumber,
            scheme: issuerInformation?.$scheme.typed,
            coScheme: issuerInformation?.$coScheme.typed,
            preferredScheme: preferredScheme(cardInfo: cardInfo, issuerInformation: issuerInformation),
            formatter: formatter
        )
        self.state = .started(startedState)
        delegate?.cardUpdateDidEmitEvent(.didStart)
    }

    // MARK: - Scheme Update

    private func issuerInformation(cardInfo: POCardUpdateInformation?) async -> POCardIssuerInformation? {
        if let scheme = cardInfo?.$scheme.typed {
            logger.debug("Needed schemes information is already set, won't resolve.")
            return POCardIssuerInformation(scheme: scheme, coScheme: cardInfo?.$coScheme.typed)
        }
        guard let iin = cardInfo?.iin ?? cardInfo?.maskedNumber.flatMap(issuerIdentificationNumber) else {
            logger.info("Unable to resolve scheme, IIN is not available")
            return nil
        }
        do {
            return try await cardsService.issuerInformation(iin: iin)
        } catch {
            logger.info("Did fail to resolve issuer information: \(error)")
        }
        return nil
    }

    private func issuerIdentificationNumber(maskedNumber: String) -> String? {
        var number = ""
        for character in maskedNumber where !character.isWhitespace {
            guard character.isNumber else {
                break
            }
            number.append(character)
        }
        let supportedLengths = [8, 6]
        for length in supportedLengths where number.count >= length {
            return String(number.prefix(length))
        }
        return nil
    }

    private func preferredScheme(
        cardInfo: POCardUpdateInformation? = nil,
        issuerInformation: POCardIssuerInformation? = nil
    ) -> POCardScheme? {
        if let scheme = cardInfo?.$preferredScheme.typed {
            return scheme
        }
        guard configuration.isSchemeSelectionAllowed else {
            return nil
        }
        return issuerInformation?.$scheme.typed
    }

    // MARK: - Failure Recovery

    private func attemptRecoverUpdateError(_ error: Error) {
        guard case .updating(let currentState) = state else {
            logger.debug("Unable to recover update error from unsupported state: \(state).")
            return
        }
        let failure: POFailure
        if let error = error as? POFailure {
            failure = error
        } else {
            logger.error("Unexpected error type: \(error).")
            failure = POFailure(message: "Something went wrong.", code: .Mobile.generic, underlyingError: error)
        }
        if delegate?.shouldContinueUpdate(after: failure) != false {
            var newState = currentState.snapshot
            newState.recentErrorMessage = errorMessage(for: failure, areParametersValid: &newState.areParametersValid)
            state = .started(newState)
            logger.debug("Did recover started state after failure: \(failure).")
        } else {
            setFailureState(failure: failure)
        }
    }

    private func errorMessage(for failure: POFailure, areParametersValid: inout Bool) -> String? {
        // todo(andrii-vysotskyi): remove hardcoded message when backend is updated with localized values
        var errorMessage: POStringResource
        switch failure.failureCode {
        case .Request.invalidCard,
             .Card.invalid,
             .Card.badTrackData,
             .Card.missingCvc,
             .Card.invalidCvc,
             .Card.failedCvc,
             .Card.failedCvcAndAvs:
            areParametersValid = false
            errorMessage = .CardUpdate.Error.cvc
        case .Mobile.cancelled, .Customer.cancelled:
            return nil
        default:
            areParametersValid = true
            errorMessage = .CardUpdate.Error.generic
        }
        return String(resource: errorMessage)
    }

    // MARK: - Failure State

    private func setFailureState(failure: POFailure) {
        if state.isSink {
            logger.debug("Already in a sink state, ignoring attempt to set failure state with: \(failure).")
        } else {
            state = .completed
            logger.info("Did fail to update card \(failure)")
            completion(.failure(failure))
        }
    }

    // MARK: - Completed State

    private func setCompletedState(card: POCard) {
        if state.isSink {
            logger.debug("Unable to complete with card: \(card), already in a sink state.")
        } else {
            logger.info("Did update card")
            state = .completed
            delegate?.cardUpdateDidEmitEvent(.didComplete)
            completion(.success(card))
        }
    }
}
