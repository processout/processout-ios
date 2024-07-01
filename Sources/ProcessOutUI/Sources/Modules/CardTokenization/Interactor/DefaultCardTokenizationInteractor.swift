//
//  DefaultCardTokenizationInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.07.2023.
//

import Foundation
@_spi(PO) import ProcessOut

// swiftlint:disable type_body_length file_length

final class DefaultCardTokenizationInteractor:
    BaseInteractor<CardTokenizationInteractorState>, CardTokenizationInteractor {

    typealias Completion = (Result<POCard, POFailure>) -> Void

    // MARK: -

    init(
        cardsService: POCardsService,
        logger: POLogger,
        configuration: POCardTokenizationConfiguration,
        completion: @escaping Completion
    ) {
        self.cardsService = cardsService
        self.logger = logger
        self.configuration = configuration
        self.completion = completion
        super.init(state: .idle)
    }

    // MARK: - CardTokenizationInteractor

    let configuration: POCardTokenizationConfiguration
    weak var delegate: POCardTokenizationDelegate?

    override func start() {
        guard case .idle = state else {
            return
        }
        delegate?.cardTokenizationDidEmitEvent(.willStart)
        let startedState = State.Started(
            number: .init(id: \.number, formatter: cardNumberFormatter),
            expiration: .init(id: \.expiration, formatter: cardExpirationFormatter),
            cvc: .init(
                id: \.cvc, shouldCollect: configuration.shouldCollectCvc, formatter: CardSecurityCodeFormatter()
            ),
            cardholderName: .init(id: \.cardholderName, shouldCollect: configuration.isCardholderNameInputVisible),
            address: defaultAddressParameters
        )
        setStateUnchecked(.started(startedState))
        delegate?.cardTokenizationDidEmitEvent(.didStart)
        logger.debug("Did start card tokenization flow")
    }

    func update(parameterId: State.ParameterId, value: String) {
        guard case .started(var startedState) = state else {
            return
        }
        let oldParameter = startedState[keyPath: parameterId]
        let formattedValue = oldParameter.formatter?.string(for: value) ?? value
        logger.debug("Will change parameter \(String(describing: parameterId)) value to '\(value)'")
        guard formattedValue != oldParameter.value else {
            logger.debug("Ignoring same value \(formattedValue)")
            return
        }
        startedState[keyPath: parameterId].value = formattedValue
        startedState[keyPath: parameterId].isValid = true
        if startedState.areParametersValid {
            logger.debug("Card information is no longer invalid, will reset error message")
            startedState.recentErrorMessage = nil
        }
        switch parameterId {
        case startedState.number.id:
            updateIssuerInformation(startedState: &startedState, oldNumber: oldParameter.value)
        case startedState.address.country.id:
            updateAddressParameters(&startedState.address)
        default:
            break
        }
        setStateUnchecked(.started(startedState))
        delegate?.cardTokenizationDidEmitEvent(.parametersChanged)
    }

    func setPreferredScheme(_ scheme: POCardScheme) {
        guard case .started(var startedState) = state else {
            return
        }
        let supportedSchemes = [
            startedState.issuerInformation?.$scheme.typed(),
            startedState.issuerInformation?.$coScheme.typed()
        ]
        logger.debug("Will change card scheme to \(scheme)")
        guard supportedSchemes.contains(scheme) else {
            logger.info(
                "Aborting attempt to select unknown '\(scheme)' scheme, supported schemes are: \(supportedSchemes)"
            )
            return
        }
        startedState.preferredScheme = scheme
        setStateUnchecked(.started(startedState))
        delegate?.cardTokenizationDidEmitEvent(.parametersChanged)
    }

    func tokenize() {
        guard case .started(let startedState) = state else {
            return
        }
        guard startedState.areParametersValid else {
            logger.debug("Ignoring attempt to tokenize invalid parameters.")
            return
        }
        logger.debug("Will tokenize card")
        delegate?.cardTokenizationDidEmitEvent(.willTokenizeCard)
        setStateUnchecked(.tokenizing(snapshot: startedState))
        let request = POCardTokenizationRequest(
            number: cardNumberFormatter.normalized(number: startedState.number.value),
            expMonth: cardExpirationFormatter.expirationMonth(from: startedState.expiration.value) ?? 0,
            expYear: cardExpirationFormatter.expirationYear(from: startedState.expiration.value) ?? 0,
            cvc: startedState.cvc.value,
            name: startedState.cardholderName.value,
            contact: convertToContact(addressParameters: startedState.address),
            preferredScheme: startedState.preferredScheme?.rawValue,
            metadata: configuration.metadata
        )
        Task { @MainActor in
            do {
                let card = try await cardsService.tokenize(request: request)
                logger.debug("Did tokenize card: \(String(describing: card))")
                delegate?.cardTokenizationDidEmitEvent(.didTokenize(card: card))
                try await delegate?.processTokenizedCard(card: card)
                setTokenizedState(card: card)
            } catch let error as POFailure {
                restoreStartedState(tokenizationFailure: error)
            } catch {
                let failure = POFailure(code: .generic(.mobile), underlyingError: error)
                restoreStartedState(tokenizationFailure: failure)
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

    // MARK: - Private Nested Types

    private enum Constants {
        static let iinLength = 6
    }

    // MARK: - Private Properties

    private let cardsService: POCardsService
    private let logger: POLogger
    private let completion: Completion

    private lazy var cardNumberFormatter = POCardNumberFormatter()
    private lazy var cardExpirationFormatter = POCardExpirationFormatter()

    private var issuerInformationCancellable: POCancellable?

    // MARK: - Tokenized State

    private func setTokenizedState(card: POCard) {
        guard case .tokenizing(let snapshot) = state else {
            return
        }
        let tokenizedState = State.Tokenized(card: card, cardNumber: snapshot.number.value)
        setStateUnchecked(.tokenized(tokenizedState))
        logger.info("Did tokenize and process card", attributes: [.cardId: card.id])
        delegate?.cardTokenizationDidEmitEvent(.didComplete)
        completion(.success(card))
    }

    // MARK: - Failure Restoration

    private func restoreStartedState(tokenizationFailure failure: POFailure) {
        guard case .tokenizing(var startedState) = state,
              isRecoverable(failure: failure),
              delegate?.shouldContinueTokenization(after: failure) != false else {
            setFailureStateUnchecked(failure: failure)
            return
        }
        var invalidParameterIds: [State.ParameterId] = []
        let errorMessage = errorMessage(for: failure, invalidParameterIds: &invalidParameterIds)
        for keyPath in invalidParameterIds {
            startedState[keyPath: keyPath].isValid = false
        }
        startedState.recentErrorMessage = errorMessage
        setStateUnchecked(.started(startedState))
        logger.debug("Did recover started state after failure: \(failure)")
    }

    private func errorMessage(for failure: POFailure, invalidParameterIds: inout [State.ParameterId]) -> String {
        // todo(andrii-vysotskyi): remove hardcoded message when backend is updated with localized values
        let errorMessage: POStringResource
        switch failure.code {
        case .generic(.requestInvalidCard), .generic(.cardInvalid):
            invalidParameterIds.append(contentsOf: [\.number, \.expiration, \.cvc, \.cardholderName])
            errorMessage = .CardTokenization.Error.card
        case .generic(.cardInvalidNumber), .generic(.cardMissingNumber):
            invalidParameterIds.append(\.number)
            errorMessage = .CardTokenization.Error.cardNumber
        case .generic(.cardInvalidExpiryDate),
             .generic(.cardMissingExpiry),
             .generic(.cardInvalidExpiryMonth),
             .generic(.cardInvalidExpiryYear):
            invalidParameterIds.append(\.expiration)
            errorMessage = .CardTokenization.Error.cardExpiration
        case .generic(.cardBadTrackData):
            invalidParameterIds.append(contentsOf: [\.expiration, \.cvc])
            errorMessage = .CardTokenization.Error.trackData
        case .generic(.cardMissingCvc),
             .generic(.cardFailedCvc),
             .generic(.cardFailedCvcAndAvs),
             .generic(.cardInvalidCvc):
            invalidParameterIds.append(\.cvc)
            errorMessage = .CardTokenization.Error.cvc
        case .generic(.cardInvalidName):
            invalidParameterIds.append(\.cardholderName)
            errorMessage = .CardTokenization.Error.cardholderName
        default:
            errorMessage = .CardTokenization.Error.generic
        }
        return String(resource: errorMessage)
    }

    private func isRecoverable(failure: POFailure) -> Bool {
        switch failure.code {
        case .generic(let genericCode) where genericCode == .cardFailed3DS:
            false
        case .networkUnreachable, .timeout, .validation, .notFound, .generic, .internal, .unknown, .cancelled:
            true
        case .authentication:
            false
        }
    }

    // MARK: - Failure State

    private func setFailureStateUnchecked(failure: POFailure) {
        setStateUnchecked(.failure(failure))
        logger.info("Did fail to tokenize/process card \(failure)")
        completion(.failure(failure))
    }

    // MARK: - Card Issuer Information

    /// Method also updates scheme and CVC if needed.
    private func updateIssuerInformation(startedState: inout State.Started, oldNumber: String) {
        let iin = issuerIdentificationNumber(number: startedState.number.value)
        if let iin, iin == issuerIdentificationNumber(number: oldNumber) {
            return
        }
        issuerInformationCancellable?.cancel()
        update(
            startedState: &startedState,
            issuerInformation: localIssuerInformation(number: startedState.number.value),
            resolvePreferredScheme: false
        )
        guard let iin else {
            return
        }
        logger.debug("Will fetch issuer information", attributes: ["IIN": iin])
        issuerInformationCancellable = cardsService.issuerInformation(iin: iin) { [logger, weak self] result in
            guard let self, case .started(var startedState) = self.state else {
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
                update(startedState: &startedState, issuerInformation: issuerInformation, resolvePreferredScheme: true)
                self.setStateUnchecked(.started(startedState))
            }
        }
    }

    /// Updates started state with given issuer information, which includes scheme and possibly CVC.
    private func update(
        startedState: inout State.Started, issuerInformation: POCardIssuerInformation?, resolvePreferredScheme: Bool
    ) {
        startedState.issuerInformation = issuerInformation
        if !resolvePreferredScheme {
            startedState.preferredScheme = nil
        } else if let issuerInformation, let delegate = delegate {
            let rawScheme = delegate.preferredScheme(issuerInformation: issuerInformation)
            startedState.preferredScheme = rawScheme.map(POCardScheme.init)
        } else {
            startedState.preferredScheme = issuerInformation?.$scheme.typed()
        }
        let securityCodeFormatter = CardSecurityCodeFormatter()
        securityCodeFormatter.scheme = issuerInformation?.$scheme.typed()
        startedState.cvc.value = securityCodeFormatter.string(from: startedState.cvc.value)
        startedState.cvc.formatter = securityCodeFormatter
    }

    private func issuerIdentificationNumber(number: String) -> String? {
        let normalizedNumber = cardNumberFormatter.normalized(number: number)
        guard normalizedNumber.count >= Constants.iinLength else {
            return nil
        }
        return String(normalizedNumber.prefix(Constants.iinLength))
    }

    /// Returns locally generated issuer information where only `scheme` property is set.
    private func localIssuerInformation(number: String) -> POCardIssuerInformation? {
        guard let scheme = CardSchemeProvider.shared.scheme(cardNumber: number) else {
            return nil
        }
        return .init(scheme: scheme)
    }

    // MARK: - Billing Address

    private var defaultAddressParameters: State.AddressParameters {
        let address = configuration.billingAddress.defaultAddress
        var addressParameters = State.AddressParameters(
            country: countryAddressParameter,
            street1: .init(id: \.address.street1, value: address?.address1 ?? ""),
            street2: .init(id: \.address.street2, value: address?.address2 ?? ""),
            city: .init(id: \.address.city, value: address?.city ?? ""),
            state: .init(id: \.address.state, value: address?.state ?? ""),
            postalCode: .init(id: \.address.postalCode, value: address?.zip ?? ""),
            specification: .default
        )
        updateAddressParameters(&addressParameters)
        return addressParameters
    }

    private var countryAddressParameter: State.Parameter {
        var countryCodes = Set(AddressSpecificationProvider.shared.countryCodes)
        if let supportedCountryCodes = configuration.billingAddress.countryCodes {
            countryCodes = countryCodes.filter(supportedCountryCodes.contains)
        }
        assert(!countryCodes.isEmpty, "At least one country code should be supported.")
        let locale = Locale.current
        let values = countryCodes
            .map { code -> State.ParameterValue in
                let displayName = locale.localizedString(forRegionCode: code)
                return State.ParameterValue(displayName: displayName ?? "", value: code)
            }
            .sorted { $0.displayName < $1.displayName }
        let configuration = configuration.billingAddress
        var defaultCountryCode = configuration.defaultAddress?.countryCode ?? locale.regionCode
        if let code = defaultCountryCode, !countryCodes.contains(code) {
            logger.info("Default country code \(code) is not supported, ignored")
            defaultCountryCode = values.first?.value
        }
        let supportedModes: Set<POBillingAddressCollectionMode> = [.automatic, .full]
        let parameter = State.Parameter(
            id: \.address.country,
            value: defaultCountryCode ?? "",
            shouldCollect: supportedModes.contains(configuration.mode),
            availableValues: values
        )
        return parameter
    }

    /// Updates parameters and specification based on currently selected country.
    private func updateAddressParameters(_ parameters: inout State.AddressParameters) {
        let countryCode = parameters.country.value
        if !parameters.country.availableValues.map(\.value).contains(countryCode) {
            assertionFailure("Country code \(countryCode) is not supported.")
        }
        let parameterss: [WritableKeyPath<State.AddressParameters, State.Parameter>: AddressSpecification.Unit] = [
            \.street1: .street,
            \.street2: .street,
            \.city: .city,
            \.state: .state,
            \.postalCode: .postcode
        ]
        let specification = AddressSpecificationProvider.shared.specification(for: countryCode)
        for (id, unit) in parameterss {
            let shouldCollect = shouldCollect(unit: unit, specification: specification, countryCode: countryCode)
            parameters[keyPath: id].shouldCollect = shouldCollect
        }
        // todo(andrii-vysotskyi): consider setting available values for state.
        parameters.specification = specification
    }

    private func shouldCollect(
        unit: AddressSpecification.Unit, specification: AddressSpecification, countryCode: String
    ) -> Bool {
        guard specification.units.contains(unit) else {
            return false
        }
        switch configuration.billingAddress.mode {
        case .automatic where unit == .postcode:
            let supportedCountryCodes: Set = ["US", "GB", "CA"]
            return supportedCountryCodes.contains(countryCode)
        case .automatic, .never:
            return false
        case .full:
            return true
        }
    }

    private func convertToContact(addressParameters parameters: State.AddressParameters) -> POContact? {
        var defaultAddress: POContact?
        if configuration.billingAddress.attachDefaultsToPaymentMethod {
            defaultAddress = configuration.billingAddress.defaultAddress
        }
        let contact = POContact(
            address1: addressValue(parameter: parameters.street1, default: defaultAddress?.address1),
            address2: addressValue(parameter: parameters.street2, default: defaultAddress?.address2),
            city: addressValue(parameter: parameters.city, default: defaultAddress?.city),
            state: addressValue(parameter: parameters.state, default: defaultAddress?.state),
            zip: addressValue(parameter: parameters.postalCode, default: defaultAddress?.zip),
            countryCode: addressValue(parameter: parameters.country, default: defaultAddress?.countryCode)
        )
        return contact
    }

    private func addressValue(parameter: State.Parameter, default defaultValue: String? = nil) -> String? {
        guard parameter.shouldCollect || configuration.billingAddress.attachDefaultsToPaymentMethod else {
            return nil
        }
        if !parameter.value.isEmpty {
            return parameter.value
        }
        return defaultValue
    }

    // MARK: - Utils

    private func setStateUnchecked(_ state: State) {
        self.state = state
    }
}

// swiftlint:enable type_body_length file_length
