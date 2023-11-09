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
        cardId: String,
        delegate: POCardUpdateDelegate?,
        completion: @escaping (Result<POCard, POFailure>) -> Void
    ) {
        self.cardsService = cardsService
        self.logger = logger
        self.cardId = cardId
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
        state = .starting
        Task {
            let cardInfo = await delegate?.cardInformation(cardId: cardId)
            let startedState = State.Started(
                cardNumber: cardInfo?.maskedNumber, scheme: cardInfo?.preferredScheme
            )
            self.state = .started(startedState)
            delegate?.cardUpdateDidEmitEvent(.didStart)
            logger.debug("Did start card update")
            await updateSchemeIfNeeded(cardInfo: cardInfo)
        }
    }

    func update(cvc: String) {
        guard case .started(var startedState) = state, startedState.cvc != cvc else {
            return
        }
        logger.debug("Will change CVC value to '\(cvc)'")
        startedState.recentErrorMessage = nil
        startedState.cvc = cvc
        state = .started(startedState)
        delegate?.cardUpdateDidEmitEvent(.parametersChanged)
    }

    @MainActor
    func submit() {
        guard case .started(let startedState) = state else {
            return
        }
        guard startedState.recentErrorMessage == nil  else {
            logger.debug("Ignoring attempt to submit invalid CVC")
            return
        }
        logger.debug("Will submit card information")
        delegate?.cardUpdateDidEmitEvent(.willUpdateCard)
        state = .updating(snapshot: startedState)
        Task {
            do {
                let request = POCardUpdateRequest(cardId: cardId, cvc: startedState.cvc)
                setCompletedState(card: try await cardsService.updateCard(request: request))
            } catch {
                recoverUpdate(from: error)
            }
        }
    }

    func cancel() {
        guard case .started = state else {
            return
        }
        let failure = POFailure(code: .cancelled)
        setFailureStateUnchecked(failure: failure)
    }

    // MARK: - Private Properties

    private let cardsService: POCardsService
    private let logger: POLogger
    private let cardId: String
    private let completion: (Result<POCard, POFailure>) -> Void

    private weak var delegate: POCardUpdateDelegate?

    // MARK: - Scheme Update

    @MainActor
    private func updateSchemeIfNeeded(cardInfo: POCardUpdateInformation?) async {
        guard let maskedNumber = cardInfo?.maskedNumber, cardInfo?.preferredScheme == nil else {
            return
        }
        guard let iin = cardInfo?.iin ?? issuerIdentificationNumber(maskedNumber: maskedNumber) else {
            logger.info("Unable to extract IIN from masked number: \(maskedNumber)")
            return
        }
        do {
            let scheme = try await cardsService.issuerInformation(iin: iin).scheme
            logger.info("Did resolve \(scheme) for masked number: \(maskedNumber)")
            switch state {
            case .started(var startedState):
                startedState.scheme = scheme
                state = .started(startedState)
            case .updating(var startedState):
                startedState.scheme = scheme
                state = .updating(snapshot: startedState)
            default:
                logger.debug("Unsupported state, scheme is ignored.")
            }
        } catch {
            logger.info("Did fail to retrieve card issuer information: \(error)")
        }
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

    // MARK: - Failure Recovery

    private func recoverUpdate(from error: Error) {
        if let failure = error as? POFailure {
            recoverUpdate(from: failure)
            return
        }
        let failure = POFailure(code: .generic(.mobile), underlyingError: error)
        recoverUpdate(from: failure)
    }

    private func recoverUpdate(from failure: POFailure) {
        guard case .updating(var startedState) = state else {
            assertionFailure("Unsupported state")
            return
        }
        let shouldContinue = delegate?.shouldContinueUpdate(after: failure) ?? true
        guard shouldContinue else {
            setFailureStateUnchecked(failure: failure)
            return
        }
        var errorMessage: StringResource
        switch failure.code {
        case .generic(.requestInvalidCard),
             .generic(.cardInvalid),
             .generic(.cardBadTrackData),
             .generic(.cardMissingCvc),
             .generic(.cardFailedCvc),
             .generic(.cardFailedCvcAndAvs):
            errorMessage = .CardUpdate.Error.cvc
        default:
            errorMessage = .CardTokenization.Error.generic
        }
        // todo(andrii-vysotskyi): remove hardcoded message when backend is updated with localized values
        startedState.recentErrorMessage = String(resource: errorMessage)
        state = .started(startedState)
        logger.debug("Did recover started state after failure: \(failure)")
    }

    private func setFailureStateUnchecked(failure: POFailure) {
        logger.info("Did fail to update card \(failure)")
        state = .completed
        completion(.failure(failure))
    }

    // MARK: - Completed State

    private func setCompletedState(card: POCard) {
        guard case .updating = state else {
            return
        }
        logger.info("Did update card")
        state = .completed
        delegate?.cardUpdateDidEmitEvent(.didComplete)
        completion(.success(card))
    }
}
