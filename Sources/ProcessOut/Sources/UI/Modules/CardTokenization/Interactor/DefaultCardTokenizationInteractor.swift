//
//  DefaultCardTokenizationInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.07.2023.
//

// swiftlint:disable:next type_body_length
final class DefaultCardTokenizationInteractor:
    BaseInteractor<CardTokenizationInteractorState>, CardTokenizationInteractor {

    typealias Completion = (Result<POCard, POFailure>) -> Void

    // MARK: -

    init(
        cardsService: POCardsService,
        invoicesService: POInvoicesService,
        customerTokensService: POCustomerTokensService,
        threeDSService: PO3DSService?,
        logger: POLogger,
        billingAddress: POContact?,
        delegate: POCardTokenizationDelegate?,
        completion: @escaping Completion
    ) {
        self.cardsService = cardsService
        self.invoicesService = invoicesService
        self.customerTokensService = customerTokensService
        self.threeDSService = threeDSService
        self.logger = logger
        self.billingAddress = billingAddress
        self.delegate = delegate
        self.completion = completion
        super.init(state: .idle)
    }

    // MARK: - CardTokenizationInteractor

    override func start() {
        guard case .idle = state else {
            return
        }
        delegate?.cardTokenizationDidEmitEvent(.willStart)
        let startedState = State.Started(
            number: .init(id: \.number, formatter: cardNumberFormatter),
            expiration: .init(id: \.expiration, formatter: cardExpirationFormatter),
            cvc: .init(id: \.cvc),
            cardholderName: .init(id: \.cardholderName)
        )
        state = .started(startedState)
        delegate?.cardTokenizationDidEmitEvent(.didStart)
        logger.debug("Did start card tokenization flow")
    }

    func update(parameterId: State.ParameterId, value: String) {
        guard case .started(var startedState) = state, startedState[keyPath: parameterId].value != value else {
            return
        }
        logger.debug("Will change parameter \(String(describing: parameterId)) value to '\(value)'")
        let oldParameterValue = startedState[keyPath: parameterId].value
        startedState[keyPath: parameterId].value = value
        startedState[keyPath: parameterId].isValid = true
        if areParametersValid(startedState: startedState) {
            logger.debug("Card information is no longer invalid, will reset error message")
            startedState.recentErrorMessage = nil
        }
        if parameterId == startedState.number.id {
            updateIssuerInformation(startedState: &startedState, oldNumber: oldParameterValue)
        }
        self.state = .started(startedState)
        delegate?.cardTokenizationDidEmitEvent(.parametersChanged)
    }

    func setPreferredScheme(_ scheme: String) {
        guard case .started(var startedState) = state else {
            return
        }
        let supportedSchemes = [startedState.issuerInformation?.scheme, startedState.issuerInformation?.coScheme]
        logger.debug("Will change card scheme to \(scheme)")
        guard supportedSchemes.contains(scheme) else {
            logger.info(
                "Aborting attempt to select unknown '\(scheme)' scheme, supported schemes are: \(supportedSchemes)"
            )
            return
        }
        startedState.preferredScheme = scheme
        state = .started(startedState)
        delegate?.cardTokenizationDidEmitEvent(.parametersChanged)
    }

    func tokenize() {
        guard case .started(let startedState) = state else {
            return
        }
        guard areParametersValid(startedState: startedState) else {
            logger.debug("Ignoring attempt to tokenize invalid parameters.")
            return
        }
        logger.debug("Will tokenize card")
        delegate?.cardTokenizationDidEmitEvent(.willTokenizeCard)
        state = .tokenizing(snapshot: startedState)
        let request = POCardTokenizationRequest(
            number: cardNumberFormatter.normalized(number: startedState.number.value),
            expMonth: cardExpirationFormatter.expirationMonth(from: startedState.expiration.value) ?? 0,
            expYear: cardExpirationFormatter.expirationYear(from: startedState.expiration.value) ?? 0,
            cvc: startedState.cvc.value,
            name: startedState.cardholderName.value,
            contact: billingAddress,
            preferredScheme: startedState.preferredScheme,
            metadata: nil // todo(andrii-vysotskyi): allow merchant to inject tokenization metadata
        )
        cardsService.tokenize(request: request) { [weak self] result in
            switch result {
            case .success(let card):
                self?.processTokenizedCard(card: card)
            case .failure(let failure):
                self?.restoreStartedState(tokenizationFailure: failure)
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

    // MARK: - Private Nested Types

    private enum Constants {
        static let iinLength = 6
    }

    // MARK: - Private Properties

    private let cardsService: POCardsService
    private let invoicesService: POInvoicesService
    private let customerTokensService: POCustomerTokensService
    private let threeDSService: PO3DSService?
    private let billingAddress: POContact?
    private let logger: POLogger
    private let completion: Completion

    private lazy var cardNumberFormatter = CardNumberFormatter()
    private lazy var cardExpirationFormatter = CardExpirationFormatter()

    private weak var delegate: POCardTokenizationDelegate?
    private var issuerInformationCancellable: POCancellable?

    // MARK: - State Management

    private func restoreStartedState(tokenizationFailure failure: POFailure) {
        let shouldContinue = delegate?.shouldContinueTokenization(after: failure) ?? true
        guard shouldContinue, case .tokenizing(var startedState) = state else {
            setFailureStateUnchecked(failure: failure)
            return
        }
        var errorMessage: String?
        var invalidParameterIds: [State.ParameterId] = []
        switch failure.code {
        case .generic(.requestInvalidCard), .generic(.cardInvalid):
            invalidParameterIds.append(contentsOf: [\.number, \.expiration, \.cvc, \.cardholderName])
            errorMessage = Strings.CardTokenization.Error.card
        case .generic(.cardInvalidNumber), .generic(.cardMissingNumber):
            invalidParameterIds.append(\.number)
            errorMessage = Strings.CardTokenization.Error.cardNumber
        case .generic(.cardInvalidExpiryDate),
             .generic(.cardMissingExpiry),
             .generic(.cardInvalidExpiryMonth),
             .generic(.cardInvalidExpiryYear):
            invalidParameterIds.append(\.expiration)
            errorMessage = Strings.CardTokenization.Error.cardExpiration
        case .generic(.cardBadTrackData):
            invalidParameterIds.append(contentsOf: [\.expiration, \.cvc])
            errorMessage = Strings.CardTokenization.Error.trackData
        case .generic(.cardMissingCvc), .generic(.cardFailedCvc), .generic(.cardFailedCvcAndAvs):
            invalidParameterIds.append(\.cvc)
            errorMessage = Strings.CardTokenization.Error.cvc
        case .generic(.cardInvalidName):
            invalidParameterIds.append(\.cardholderName)
            errorMessage = Strings.CardTokenization.Error.cardholderName
        default:
            errorMessage = Strings.CardTokenization.Error.generic
        }
        for keyPath in invalidParameterIds {
            startedState[keyPath: keyPath].isValid = false
        }
        // todo(andrii-vysotskyi): remove hardcoded message when backend is updated with localized values
        startedState.recentErrorMessage = errorMessage
        state = .started(startedState)
        logger.debug("Did recover started state after failure: \(failure)")
    }

    private func processTokenizedCard(card: POCard) {
        guard case .tokenizing = state else {
            return
        }
        logger.debug("Did tokenize card: \(String(describing: card))")
        delegate?.cardTokenizationDidEmitEvent(.didTokenize(card: card))
        if let delegate {
            delegate.processTokenizedCard(card: card) { [weak self] result in
                switch result {
                case .success(let .authorizeInvoice(request)):
                    self?.authorizeInvoice(card: card, request: request)
                case .success(let .assignToken(request)):
                    self?.assignCustomerToken(card: card, request: request)
                case .success(nil):
                    self?.setTokenizedState(card: card)
                case .failure(let error):
                    let failure = POFailure(code: .generic(.mobile), underlyingError: error)
                    self?.restoreStartedState(tokenizationFailure: failure)
                }
            }
        } else {
            setTokenizedState(card: card)
        }
    }

    private func authorizeInvoice(card: POCard, request: POInvoiceAuthorizationRequest) {
        guard case .tokenizing = state else {
            return
        }
        logger.debug("Will authorize invoice", attributes: ["InvoiceId": request.invoiceId, "CardId": card.id])
        guard let threeDSService else {
            preconditionFailure("3DS service must be set to authorize invoice.")
        }
        invoicesService.authorizeInvoice(request: request, threeDSService: threeDSService) { [weak self] result in
            self?.setTokenizedState(result: result, card: card)
        }
    }

    private func assignCustomerToken(card: POCard, request: POAssignCustomerTokenRequest) {
        guard case .tokenizing = state else {
            return
        }
        logger.debug("Will assign customer token", attributes: ["TokenId": request.tokenId, "CardId": card.id])
        guard let threeDSService else {
            preconditionFailure("3DS service must be set to authorize invoice.")
        }
        customerTokensService.assignCustomerToken(
            request: request,
            threeDSService: threeDSService,
            completion: { [weak self] result in
                self?.setTokenizedState(result: result, card: card)
            }
        )
    }

    private func setTokenizedState<T>(result: Result<T, POFailure>, card: POCard) {
        switch result {
        case .success:
            setTokenizedState(card: card)
        case .failure(let failure):
            restoreStartedState(tokenizationFailure: failure)
        }
    }

    private func setTokenizedState(card: POCard) {
        guard case .tokenizing(let snapshot) = state else {
            return
        }
        let tokenizedState = State.Tokenized(card: card, cardNumber: snapshot.number.value)
        state = .tokenized(tokenizedState)
        logger.info("Did tokenize/process card", attributes: ["CardId": card.id])
        delegate?.cardTokenizationDidEmitEvent(.didComplete)
        completion(.success(card))
    }

    private func setFailureStateUnchecked(failure: POFailure) {
        state = .failure(failure)
        logger.info("Did fail to tokenize/process card \(failure)")
        completion(.failure(failure))
    }

    // MARK: - Card Issuer Information

    private func updateIssuerInformation(startedState: inout State.Started, oldNumber: String) {
        if let iin = issuerIdentificationNumber(number: startedState.number.value) {
            guard iin != issuerIdentificationNumber(number: oldNumber) else {
                return
            }
            startedState.issuerInformation = issuerInformation(number: startedState.number.value)
            startedState.preferredScheme = nil
            issuerInformationCancellable?.cancel()
            logger.debug("Will fetch issuer information", attributes: ["IIN": iin])
            issuerInformationCancellable = cardsService.issuerInformation(iin: iin) { [logger, weak self] result in
                guard case .started(var startedState) = self?.state else {
                    return
                }
                switch result {
                case .failure(let failure) where failure.code == .cancelled:
                    break
                case .failure(let failure):
                    // Inability to select co-scheme is considered minor issue and we still want
                    // users to be able to continue tokenization. So errors are silently ignored.
                    logger.info("Did fail to fetch issuer information: \(failure)", attributes: ["IIN": iin])
                case .success(let issuerInformation):
                    startedState.issuerInformation = issuerInformation
                    startedState.preferredScheme = self?.delegate?.preferredScheme(issuerInformation: issuerInformation)
                    self?.state = .started(startedState)
                }
            }
        } else {
            startedState.issuerInformation = issuerInformation(number: startedState.number.value)
            startedState.preferredScheme = nil
        }
    }

    private func issuerIdentificationNumber(number: String) -> String? {
        let normalizedNumber = cardNumberFormatter.normalized(number: number)
        guard normalizedNumber.count >= Constants.iinLength else {
            return nil
        }
        return String(normalizedNumber.prefix(Constants.iinLength))
    }

    /// Returns locally generated issuer information where only `scheme` property is set.
    private func issuerInformation(number: String) -> POCardIssuerInformation? {
        guard let scheme = CardTokenizationSchemeProvider().scheme(cardNumber: number) else {
            return nil
        }
        return .init(scheme: scheme, coScheme: nil, type: nil, bankName: nil, brand: nil, category: nil)
    }

    // MARK: - Utils

    private func areParametersValid(startedState: State.Started) -> Bool {
        let parameters = [startedState.number, startedState.expiration, startedState.cvc, startedState.cardholderName]
        return parameters.allSatisfy(\.isValid)
    }
}
