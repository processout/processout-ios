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
        delegate: POCardTokenizationDelegate?,
        completion: @escaping Completion
    ) {
        self.cardsService = cardsService
        self.invoicesService = invoicesService
        self.customerTokensService = customerTokensService
        self.threeDSService = threeDSService
        self.logger = logger
        self.delegate = delegate
        self.completion = completion
        super.init(state: .idle)
    }

    // MARK: - CardTokenizationInteractor

    override func start() {
        guard case .idle = state else {
            return
        }
        let startedState = State.Started(
            number: .init(id: \.number, formatter: cardNumberFormatter),
            expiration: .init(id: \.expiration, formatter: cardExpirationFormatter),
            cvc: .init(id: \.cvc),
            cardholderName: .init(id: \.cardholderName),
            prefersCoScheme: false
        )
        state = .started(startedState)
    }

    func update(parameterId: State.ParameterId, value: String) {
        guard case .started(var startedState) = state, startedState[keyPath: parameterId].value != value else {
            return
        }
        let oldParameterValue = startedState[keyPath: parameterId].value
        startedState[keyPath: parameterId].value = value
        startedState[keyPath: parameterId].isValid = true
        if areParametersValid(startedState: startedState) {
            startedState.recentErrorMessage = nil
        }
        self.state = .started(startedState)
        if parameterId == startedState.number.id {
            updateCardIssuerInformation(oldNumber: oldParameterValue)
        }
    }

    func setPrefersCoScheme(_ prefersCoScheme: Bool) {
        guard case .started(var startedState) = state else {
            return
        }
        startedState.prefersCoScheme = prefersCoScheme
        state = .started(startedState)
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
        let preferredScheme = startedState.prefersCoScheme
            ? startedState.issuerInformation?.coScheme
            : startedState.issuerInformation?.scheme
        let request = POCardTokenizationRequest(
            number: cardNumberFormatter.normalized(number: startedState.number.value),
            expMonth: cardExpirationFormatter.expirationMonth(from: startedState.expiration.value) ?? 0,
            expYear: cardExpirationFormatter.expirationYear(from: startedState.expiration.value) ?? 0,
            cvc: startedState.cvc.value,
            name: startedState.cardholderName.value,
            contact: nil, // todo(andrii-vysotskyi): collect contact information
            preferredScheme: preferredScheme,
            metadata: nil // todo(andrii-vysotskyi): allow merchant to inject tokenization metadata
        )
        cardsService.tokenize(request: request) { [weak self] result in
            switch result {
            case .success(let card):
                self?.processTokenizedCard(card: card)
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

    // MARK: - Private Nested Types

    private enum Constants {
        static let iinLength = 6
    }

    // MARK: - Private Properties

    private let cardsService: POCardsService
    private let invoicesService: POInvoicesService
    private let customerTokensService: POCustomerTokensService
    private let threeDSService: PO3DSService?
    private let logger: POLogger
    private let completion: Completion

    private lazy var cardNumberFormatter = CardNumberFormatter()
    private lazy var cardExpirationFormatter = CardExpirationFormatter()

    private weak var delegate: POCardTokenizationDelegate?
    private var issuerInformationCancellable: POCancellable?

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

    private func processTokenizedCard(card: POCard) {
        guard case .tokenizing = state else {
            return
        }
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
                    self?.setFailureStateUnchecked(failure: failure)
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
        guard let threeDSService else {
            preconditionFailure("3DS service must be set to authorize invoice.")
        }
        invoicesService.authorizeInvoice(request: request, threeDSService: threeDSService) { [weak self] result in
            switch result {
            case .success:
                self?.setTokenizedState(card: card)
            case .failure(let failure):
                // todo(andrii-vysotskyi): decide if implementation should attempt to recover
                self?.setFailureStateUnchecked(failure: failure)
            }
        }
    }

    private func assignCustomerToken(card: POCard, request: POAssignCustomerTokenRequest) {
        guard case .tokenizing = state else {
            return
        }
        guard let threeDSService else {
            preconditionFailure("3DS service must be set to authorize invoice.")
        }
        customerTokensService.assignCustomerToken(
            request: request,
            threeDSService: threeDSService,
            completion: { [weak self] result in
                switch result {
                case .success:
                    self?.setTokenizedState(card: card)
                case .failure(let failure):
                    // todo(andrii-vysotskyi): decide if implementation should attempt to recover
                    self?.setFailureStateUnchecked(failure: failure)
                }
            }
        )
    }

    private func setTokenizedState(card: POCard) {
        guard case .tokenizing(let snapshot) = state else {
            return
        }
        let tokenizedState = State.Tokenized(card: card, cardNumber: snapshot.number.value)
        state = .tokenized(tokenizedState)
        completion(.success(card))
    }

    private func setFailureStateUnchecked(failure: POFailure) {
        state = .failure(failure)
        completion(.failure(failure))
    }

    // MARK: - Card Issuer Information

    private func updateCardIssuerInformation(oldNumber: String) {
        guard case .started(var startedState) = state else {
            return
        }
        startedState.issuerInformation = issuerInformation(number: startedState.number.value)
        startedState.prefersCoScheme = false
        if let iin = issuerIdentificationNumber(number: startedState.number.value) {
            guard iin != issuerIdentificationNumber(number: oldNumber) else {
                return // IIN didn't change so abort.
            }
            state = .started(startedState)
            issuerInformationCancellable?.cancel()
            issuerInformationCancellable = cardsService.issuerInformation(iin: iin) { [weak self] result in
                guard case .started(var startedState) = self?.state else {
                    return
                }
                switch result {
                case .success(let issuerInformation):
                    startedState.issuerInformation = issuerInformation
                case .failure(let failure) where failure.code == .cancelled:
                    break
                case .failure:
                    break // todo(andrii-vysotskyi): ask merchant whether this error should fail whole flow
                }
                self?.state = .started(startedState)
            }
        } else {
            state = .started(startedState)
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
        struct Issuer {
            let scheme: String
            let leading: ClosedRange<Int>
            let length: Int
        }
        // Based on https://www.bincodes.com/bin-list
        // todo(andrii-vysotskyi): support more schemes
        let issuers: [Issuer] = [
            .init(scheme: "visa", leading: 4...4, length: 1),
            .init(scheme: "mastercard", leading: 2221...2720, length: 4),
            .init(scheme: "mastercard", leading: 51...55, length: 2),
            .init(scheme: "china union pay", leading: 62...62, length: 2),
            .init(scheme: "american express", leading: 34...34, length: 2),
            .init(scheme: "american express", leading: 37...37, length: 2),
            .init(scheme: "discover", leading: 6011...6011, length: 4),
            .init(scheme: "discover", leading: 622126...622925, length: 6),
            .init(scheme: "discover", leading: 644...649, length: 3),
            .init(scheme: "discover", leading: 65...65, length: 2)
        ]
        let normalizedNumber = cardNumberFormatter.normalized(number: number)
        let issuer = issuers.first { issuer in
            guard let leading = Int(normalizedNumber.prefix(issuer.length)) else {
                return false
            }
            return issuer.leading.contains(leading)
        }
        guard let issuer else {
            return nil
        }
        return .init(scheme: issuer.scheme, coScheme: nil, type: nil, bankName: nil, brand: nil, category: nil)
    }

    // MARK: - Utils

    private func areParametersValid(startedState: State.Started) -> Bool {
        let parameters = [startedState.number, startedState.expiration, startedState.cvc, startedState.cardholderName]
        return parameters.allSatisfy(\.isValid)
    }
}
