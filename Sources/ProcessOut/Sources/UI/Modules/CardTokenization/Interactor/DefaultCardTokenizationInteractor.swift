//
//  DefaultCardTokenizationInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.07.2023.
//

final class DefaultCardTokenizationInteractor:
    BaseInteractor<CardTokenizationInteractorState>, CardTokenizationInteractor {

    init(
        cardsService: POCardsService,
        customerTokensService: POCustomerTokensService,
        invoicesService: POInvoicesService,
        threeDSService: PO3DSService,
        logger: POLogger
    ) {
        self.cardsService = cardsService
        self.customerTokensService = customerTokensService
        self.invoicesService = invoicesService
        self.threeDSService = threeDSService
        self.logger = logger
        super.init(state: .idle)
    }

    // MARK: - CardTokenizationInteractor

    override func start() {
        guard case .idle = state else {
            return
        }
        let startedState = State.Started(
            number: nil, expMonth: nil, expYear: nil, cvc: nil, cardholderName: nil, recentErrorMessage: nil
        )
        state = .started(startedState)
    }

    func update(parameterAt path: WritableKeyPath<State.Started, State.Parameter?>, value: String) {
        guard case .started(var startedState) = state else {
            return
        }
        startedState[keyPath: path] = .init(value: value, isValid: nil)
        self.state = .started(startedState)
    }

    func tokenize() {
        guard case .started(let startedState) = state else {
            return
        }
        let parameters = [
            // swiftlint:disable:next line_length
            startedState.number, startedState.expMonth, startedState.expYear, startedState.cvc, startedState.cardholderName
        ]
        guard parameters.allSatisfy({ $0?.isValid != false }) else {
            logger.debug("Ignoring attempt to tokenize invalid parameters.")
            return
        }
        state = .tokenizing(snapshot: startedState)
        // todo(andrii-vysotskyi): pass contact and metadata information
        let request = POCardTokenizationRequest(
            number: startedState.number?.value ?? "",
            expMonth: startedState.expMonth.flatMap { Int($0.value) } ?? 0,
            expYear: startedState.expYear.flatMap { Int($0.value) } ?? 0,
            cvc: startedState.cvc?.value,
            name: startedState.cardholderName?.value,
            contact: nil,
            metadata: nil
        )
        cardsService.tokenize(request: request) { [weak self] result in
            switch result {
            case .success(let card):
                self?.setTokenizedStateUnchecked(card: card, cardNumber: request.number)
            case .failure(let failure):
                self?.restoreStartedStateAfterTokenizationFailure(failure)
            }
        }
    }

    func cancel() {
        // ignored
    }

    // MARK: - Private Properties

    private let cardsService: POCardsService
    private let customerTokensService: POCustomerTokensService
    private let invoicesService: POInvoicesService
    private let threeDSService: PO3DSService
    private let logger: POLogger

    // MARK: - State Management

    // swiftlint:disable:next cyclomatic_complexity
    private func restoreStartedStateAfterTokenizationFailure(_ failure: POFailure) {
        guard case .tokenizing(var startedState) = state, case .generic(let genericFailureCode) = failure.code else {
            setFailureStateUnchecked(failure: failure)
            return
        }
        var invalidParameters: [WritableKeyPath<State.Started, State.Parameter?>] = []
        switch genericFailureCode {
        case .requestInvalidCard, .cardInvalid:
            invalidParameters.append(contentsOf: [\.number, \.expMonth, \.expYear, \.cvc, \.cardholderName])
        case .cardInvalidNumber, .cardMissingNumber:
            invalidParameters.append(\.number)
        case .cardInvalidExpiryDate, .cardMissingExpiry:
            invalidParameters.append(contentsOf: [\.expMonth, \.expYear])
        case .cardInvalidExpiryMonth:
            invalidParameters.append(\.expMonth)
        case .cardInvalidExpiryYear:
            invalidParameters.append(\.expYear)
        case .cardBadTrackData:
            invalidParameters.append(contentsOf: [\.expMonth, \.expYear, \.cvc])
        case .cardMissingCvc, .cardFailedCvc, .cardFailedCvcAndAvs:
            invalidParameters.append(\.cvc)
        case .cardInvalidName:
            invalidParameters.append(\.cardholderName)
        default:
            setFailureStateUnchecked(failure: failure)
            return
        }
        for keyPath in invalidParameters {
            startedState[keyPath: keyPath]?.isValid = false
        }
        startedState.recentErrorMessage = failure.message
        state = .started(startedState)
    }

    private func setTokenizedStateUnchecked(card: POCard, cardNumber: String) {
        let tokenizedState = State.Tokenized(card: card, cardNumber: cardNumber)
        state = .tokenized(tokenizedState)
    }

    private func setFailureStateUnchecked(failure: POFailure) {
        state = .failure(failure)
    }
}
