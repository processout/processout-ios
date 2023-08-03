//
//  DefaultCardTokenizationInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.07.2023.
//

final class DefaultCardTokenizationInteractor:
    BaseInteractor<CardTokenizationInteractorState>, CardTokenizationInteractor {

    typealias Completion = (Result<POCard, POFailure>) -> Void

    // MARK: -

    init(cardsService: POCardsService, logger: POLogger, completion: @escaping Completion) {
        self.cardsService = cardsService
        self.logger = logger
        self.completion = completion
        super.init(state: .idle)
    }

    // MARK: - CardTokenizationInteractor

    override func start() {
        guard case .idle = state else {
            return
        }
        let startedState = State.Started(
            number: .init(id: \.number),
            expiration: .init(id: \.expiration),
            cvc: .init(id: \.cvc),
            cardholderName: .init(id: \.cardholderName)
        )
        state = .started(startedState)
    }

    func update(parameterId: State.ParameterId, value: String) {
        guard case .started(var startedState) = state, startedState[keyPath: parameterId].value != value else {
            return
        }
        startedState[keyPath: parameterId] = .init(id: parameterId, value: value, isValid: true)
        if areParametersValid(startedState: startedState) {
            startedState.recentErrorMessage = nil
        }
        self.state = .started(startedState)
    }

    func tokenize() {
        guard case .started(let startedState) = state else {
            return
        }
        guard areParametersValid(startedState: startedState) else {
            logger.debug("Ignoring attempt to tokenize invalid parameters.")
            return
        }
        state = .tokenizing(snapshot: startedState)
        let request = POCardTokenizationRequest(
            number: cardNumberFormatter.normalized(number: startedState.number.value),
            expMonth: cardExpirationFormatter.expirationMonth(from: startedState.expiration.value) ?? 0,
            expYear: cardExpirationFormatter.expirationYear(from: startedState.expiration.value) ?? 0,
            cvc: startedState.cvc.value,
            name: startedState.cardholderName.value,
            contact: nil, // todo(andrii-vysotskyi): pass contact and metadata
            metadata: nil
        )
        cardsService.tokenize(request: request) { [weak self] result in
            switch result {
            case .success(let card):
                self?.setTokenizedStateUnchecked(card: card, cardNumber: startedState.number.value)
            case .failure(let failure):
                self?.restoreStartedStateAfterTokenizationFailure(failure)
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
    private let completion: Completion

    private lazy var cardNumberFormatter = CardNumberFormatter()
    private lazy var cardExpirationFormatter = CardExpirationFormatter()

    // MARK: - State Management

    private func restoreStartedStateAfterTokenizationFailure(_ failure: POFailure) {
        guard case .tokenizing(var startedState) = state, case .generic(let genericFailureCode) = failure.code else {
            setFailureStateUnchecked(failure: failure)
            return
        }
        var invalidParameterIds: [State.ParameterId] = []
        switch genericFailureCode {
        case .requestInvalidCard, .cardInvalid:
            invalidParameterIds.append(contentsOf: [\.number, \.expiration, \.cvc, \.cardholderName])
        case .cardInvalidNumber, .cardMissingNumber:
            invalidParameterIds.append(\.number)
        case .cardInvalidExpiryDate, .cardMissingExpiry, .cardInvalidExpiryMonth, .cardInvalidExpiryYear:
            invalidParameterIds.append(\.expiration)
        case .cardBadTrackData:
            invalidParameterIds.append(contentsOf: [\.expiration, \.cvc])
        case .cardMissingCvc, .cardFailedCvc, .cardFailedCvcAndAvs:
            invalidParameterIds.append(\.cvc)
        case .cardInvalidName:
            invalidParameterIds.append(\.cardholderName)
        default:
            setFailureStateUnchecked(failure: failure)
            return
        }
        for keyPath in invalidParameterIds {
            startedState[keyPath: keyPath].isValid = false
        }
        startedState.recentErrorMessage = failure.message
        state = .started(startedState)
    }

    private func setTokenizedStateUnchecked(card: POCard, cardNumber: String) {
        let tokenizedState = State.Tokenized(card: card, cardNumber: cardNumber)
        state = .tokenized(tokenizedState)
        completion(.success(card))
    }

    private func setFailureStateUnchecked(failure: POFailure) {
        state = .failure(failure)
        completion(.failure(failure))
    }

    // MARK: - Utils

    private func areParametersValid(startedState: State.Started) -> Bool {
        let parameters = [startedState.number, startedState.expiration, startedState.cvc, startedState.cardholderName]
        return parameters.allSatisfy(\.isValid)
    }
}
