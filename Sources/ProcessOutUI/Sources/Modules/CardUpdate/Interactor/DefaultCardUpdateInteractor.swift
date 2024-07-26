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
        if let cardInfo = configuration.cardInformation {
            setStartedStateUnchecked(cardInfo: cardInfo)
        } else {
            state = .starting
            Task {
                let cardInfo = await delegate?.cardInformation(cardId: configuration.cardId)
                setStartedStateUnchecked(cardInfo: cardInfo)
            }
        }
    }

    func update(cvc: String) {
        guard case .started(var startedState) = state else {
            return
        }
        logger.debug("Will change CVC to '\(cvc)'")
        let formatted = cardSecurityCodeFormatter.string(from: cvc)
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
            logger.info(
                "Aborting attempt to select unknown '\(scheme)' scheme, supported schemes are: \(supportedSchemes)"
            )
            return
        }
        startedState.preferredScheme = scheme
        state = .started(startedState)
        delegate?.cardUpdateDidEmitEvent(.parametersChanged)
    }

    func submit() {
        guard case .started(let startedState) = state else {
            return
        }
        guard startedState.areParametersValid else {
            logger.debug("Ignoring attempt to submit invalid parameters.")
            return
        }
        logger.debug("Will submit card information")
        delegate?.cardUpdateDidEmitEvent(.willUpdateCard)
        state = .updating(snapshot: startedState)
        Task {
            do {
                let request = POCardUpdateRequest(
                    cardId: configuration.cardId,
                    cvc: startedState.cvc,
                    preferredScheme: startedState.preferredScheme?.rawValue
                )
                setCompletedState(card: try await cardsService.updateCard(request: request))
            } catch {
                recoverUpdate(from: error)
            }
        }
    }

    override func cancel() {
        guard case .started = state else {
            return
        }
        let failure = POFailure(code: .cancelled)
        setFailureStateUnchecked(failure: failure)
    }

    // MARK: - Private Properties

    private weak var delegate: POCardUpdateDelegate?

    private let cardsService: POCardsService
    private let logger: POLogger
    private let configuration: POCardUpdateConfiguration
    private let completion: (Result<POCard, POFailure>) -> Void

    private lazy var cardSecurityCodeFormatter = CardSecurityCodeFormatter()

    // MARK: - Started State

    private func setStartedStateUnchecked(cardInfo: POCardUpdateInformation?) {
        cardSecurityCodeFormatter.scheme = cardInfo?.$scheme.typed
        let startedState = State.Started(
            cardNumber: cardInfo?.maskedNumber,
            scheme: cardInfo?.$scheme.typed,
            coScheme: cardInfo?.$coScheme.typed,
            preferredScheme: preferredScheme(cardInfo: cardInfo),
            formatter: cardSecurityCodeFormatter
        )
        self.state = .started(startedState)
        delegate?.cardUpdateDidEmitEvent(.didStart)
        logger.debug("Did start card update")
        Task {
            await updateSchemeIfNeeded(cardInfo: cardInfo)
        }
    }

    // MARK: - Scheme Update

    private func updateSchemeIfNeeded(cardInfo: POCardUpdateInformation?) async {
        guard cardInfo?.scheme == nil || cardInfo?.coScheme == nil else {
            logger.debug("Needed schemes information is already set, ignored")
            return
        }
        guard let iin = cardInfo?.iin ?? cardInfo?.maskedNumber.flatMap(issuerIdentificationNumber) else {
            logger.info("Unable to resolve scheme, IIN is not available")
            return
        }
        do {
            let issuerInformation = try await cardsService.issuerInformation(iin: iin)
            logger.info("Did resolve issuer info: \(issuerInformation)")
            switch state {
            case .started(var startedState):
                update(state: &startedState, with: issuerInformation)
                state = .started(startedState)
            case .updating(var startedState):
                update(state: &startedState, with: issuerInformation)
                state = .updating(snapshot: startedState)
            default:
                logger.debug("Unsupported state, resolved scheme info is ignored")
                return
            }
        } catch {
            logger.info("Did fail to resolve scheme: \(error)")
        }
    }

    /// - NOTE: Method updates interactor's CSC formatter as well.
    private func update(state: inout State.Started, with issuerInformation: POCardIssuerInformation) {
        cardSecurityCodeFormatter.scheme = issuerInformation.$scheme.typed
        state.scheme = issuerInformation.$scheme.typed
        state.coScheme = issuerInformation.$coScheme.typed
        state.preferredScheme = state.preferredScheme ?? preferredScheme(issuerInformation: issuerInformation)
        state.cvc = cardSecurityCodeFormatter.string(from: state.cvc)
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
        } else {
            let failure = POFailure(code: .generic(.mobile), underlyingError: error)
            recoverUpdate(from: failure)
        }
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
             .generic(.cardInvalidCvc),
             .generic(.cardFailedCvc),
             .generic(.cardFailedCvcAndAvs):
            startedState.areParametersValid = false
            errorMessage = .CardUpdate.Error.cvc
        default:
            startedState.areParametersValid = true
            errorMessage = .CardUpdate.Error.generic
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

    // MARK: - Preferred Scheme

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
        return cardInfo?.$scheme.typed ?? issuerInformation?.$scheme.typed
    }
}
