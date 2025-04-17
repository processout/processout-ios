//
//  DefaultCardTokenizationInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.07.2023.
//

import Foundation
import Combine
@_spi(PO) import ProcessOut

// swiftlint:disable type_body_length file_length

final class DefaultCardTokenizationInteractor:
    BaseInteractor<CardTokenizationInteractorState>, CardTokenizationInteractor {

    init(
        cardsService: POCardsService,
        logger: POLogger,
        configuration: POCardTokenizationConfiguration,
        completion: @escaping (Result<POCard, POFailure>) -> Void
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
        let newState = State.Started(
            number: .init(id: \.number, formatter: cardNumberFormatter),
            expiration: .init(id: \.expiration, formatter: cardExpirationFormatter),
            cvc: .init(id: \.cvc, shouldCollect: configuration.cvc != nil, formatter: CardSecurityCodeFormatter()),
            cardholderName: .init(id: \.cardholderName, shouldCollect: configuration.cardholderName != nil),
            address: defaultAddressParameters
        )
        state = .started(newState)
        delegate?.cardTokenizationDidEmitEvent(.didStart)
        logger.debug("Did start card tokenization flow")
    }

    func update(with scannedCard: POScannedCard) {
        guard case .started(let currentState) = state else {
            return
        }
        logger.debug("Will update parameters with scanned card: '\(scannedCard)'")
        var newState = currentState
        newState.number.value = cardNumberFormatter.string(from: scannedCard.number)
        newState.number.isValid = true
        if let expiration = scannedCard.expiration {
            newState.expiration.value = cardExpirationFormatter.string(from: expiration.description)
            newState.expiration.isValid = true
        }
        if newState.cardholderName.shouldCollect, let cardholderName = scannedCard.cardholderName {
            newState.cardholderName.value = cardholderName
            newState.cardholderName.isValid = true
        }
        // swiftlint:disable:next line_length
        guard newState.number.value != currentState.number.value || newState.expiration.value != currentState.expiration.value else {
            logger.debug("Ignoring same card details \(scannedCard)")
            return
        }
        if newState.areParametersValid {
            logger.debug("Card information is no longer invalid, will reset error message")
            newState.recentErrorMessage = nil
        }
        updateCardInformation(in: &newState, cardNumber: newState.number.value)
        state = .started(newState)
        delegate?.cardTokenizationDidEmitEvent(.parametersChanged)
    }

    func update(parameterId: State.ParameterId, value: String) {
        guard case .started(var newState) = state else {
            return
        }
        let oldParameter = newState[keyPath: parameterId]
        let formattedValue = oldParameter.formatter?.string(for: value) ?? value
        logger.debug("Will change parameter \(String(describing: parameterId)) value to '\(value)'")
        guard formattedValue != oldParameter.value else {
            logger.debug("Ignoring same value \(formattedValue)")
            return
        }
        newState[keyPath: parameterId].value = formattedValue
        newState[keyPath: parameterId].isValid = true
        if newState.areParametersValid {
            logger.debug("Card information is no longer invalid, will reset error message")
            newState.recentErrorMessage = nil
        }
        switch parameterId {
        case newState.number.id:
            updateCardInformation(in: &newState, cardNumber: formattedValue)
        case newState.address.country.id:
            updateAddressParameters(&newState.address)
        default:
            break
        }
        state = .started(newState)
        delegate?.cardTokenizationDidEmitEvent(.parametersChanged)
    }

    func setPreferredScheme(_ scheme: POCardScheme) {
        guard case .started(var newState) = state,
              let supportedSchemes = newState.cardInformation.supportedEligibleSchemes else {
            return
        }
        logger.debug("Will change card scheme to \(scheme)")
        guard supportedSchemes.contains(scheme) else {
            logger.info("Can't select unknown '\(scheme)' scheme, supported schemes are: \(supportedSchemes)")
            return
        }
        newState.cardInformation.preferredScheme = scheme
        state = .started(newState)
        delegate?.cardTokenizationDidEmitEvent(.parametersChanged)
    }

    func setShouldSaveCard(_ shouldSaveCard: Bool) {
        guard case .started(var newState) = state else {
            return
        }
        logger.debug("Will change card saving selection to \(shouldSaveCard)")
        newState.shouldSaveCard = shouldSaveCard
        state = .started(newState)
        delegate?.cardTokenizationDidEmitEvent(.parametersChanged)
    }

    func tokenize() {
        guard case .started(let currentState) = state else {
            return
        }
        guard currentState.areParametersValid else {
            logger.debug("Ignoring attempt to tokenize invalid parameters.")
            return
        }
        logger.debug("Will tokenize card")
        delegate?.cardTokenizationDidEmitEvent(.willTokenizeCard)
        let task = Task { @MainActor in
            do {
                let card = try await cardsService.tokenize(
                    request: createCardTokenizationRequest(with: currentState)
                )
                logger.debug("Did tokenize card: \(String(describing: card))")
                delegate?.cardTokenizationDidEmitEvent(.didTokenize(card: card))
                try await delegate?.cardTokenization(didTokenizeCard: card, shouldSaveCard: currentState.shouldSaveCard)
                setTokenizedState(card: card)
            } catch {
                attemptRecoverTokenizationError(error)
            }
        }
        let tokenizingState = State.Tokenizing(snapshot: currentState, task: task)
        state = .tokenizing(tokenizingState)
    }

    override func cancel() {
        if case .tokenizing(let currentState) = state {
            currentState.task.cancel()
        }
        setFailureState(failure: POFailure(message: "Card tokenization has been canceled.", code: .Mobile.cancelled))
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let iinLength = 8
    }

    // MARK: - Private Properties

    private let cardsService: POCardsService
    private let logger: POLogger
    private let completion: (Result<POCard, POFailure>) -> Void

    private let cardNumberFormatter = POCardNumberFormatter()
    private let cardExpirationFormatter = POCardExpirationFormatter()

    // MARK: - Tokenized State

    private func setTokenizedState(card: POCard) {
        guard case .tokenizing = state else {
            return
        }
        state = .tokenized
        logger.info("Did tokenize and process card", attributes: [.cardId: card.id])
        delegate?.cardTokenizationDidEmitEvent(.didComplete)
        completion(.success(card))
    }

    // MARK: - Failure Restoration

    private func attemptRecoverTokenizationError(_ error: Error) {
        guard case .tokenizing(let currentState) = state else {
            logger.debug("Unable to recover tokenization failure from unsupported state: \(state)")
            return
        }
        let failure: POFailure
        if let error = error as? POFailure {
            failure = error
        } else {
            logger.error("Unexpected error type: \(error).")
            failure = POFailure(message: "Something went wrong.", code: .Mobile.generic, underlyingError: error)
        }
        if delegate?.shouldContinueTokenization(after: failure) != false {
            var newState = currentState.snapshot
            var invalidParameterIds: [State.ParameterId] = []
            newState.recentErrorMessage = errorMessage(for: failure, invalidParameterIds: &invalidParameterIds)
            for keyPath in invalidParameterIds {
                newState[keyPath: keyPath].isValid = false
            }
            state = .started(newState)
            logger.debug("Did recover started state after failure: \(failure)")
        } else {
            setFailureState(failure: failure)
        }
    }

    private func errorMessage(for failure: POFailure, invalidParameterIds: inout [State.ParameterId]) -> String? {
        // todo(andrii-vysotskyi): remove hardcoded message when backend is updated with localized values
        let errorMessage: POStringResource
        switch failure.failureCode {
        case .Request.invalidCard, .Card.invalid:
            invalidParameterIds.append(contentsOf: [\.number, \.expiration, \.cvc, \.cardholderName])
            errorMessage = .CardTokenization.Error.card
        case .Card.invalidNumber, .Card.missingNumber:
            invalidParameterIds.append(\.number)
            errorMessage = .CardTokenization.Error.cardNumber
        case .Card.invalidExpiryDate,
             .Card.missingExpiry,
             .Card.invalidExpiryMonth,
             .Card.invalidExpiryYear:
            invalidParameterIds.append(\.expiration)
            errorMessage = .CardTokenization.Error.cardExpiration
        case .Card.badTrackData:
            invalidParameterIds.append(contentsOf: [\.expiration, \.cvc])
            errorMessage = .CardTokenization.Error.trackData
        case .Card.missingCvc,
             .Card.failedCvc,
             .Card.failedCvcAndAvs,
             .Card.invalidCvc:
            invalidParameterIds.append(\.cvc)
            errorMessage = .CardTokenization.Error.cvc
        case .Card.invalidName:
            invalidParameterIds.append(\.cardholderName)
            errorMessage = .CardTokenization.Error.cardholderName
        case .Mobile.cancelled, .Customer.cancelled:
            return nil
        default:
            errorMessage = .CardTokenization.Error.generic
        }
        return String(resource: errorMessage)
    }

    // MARK: - Failure State

    private func setFailureState(failure: POFailure) {
        if state.isSink {
            logger.debug("Already in a sink state, ignoring attempt to set failure state with: \(failure).")
        } else {
            state = .failure(failure)
            logger.info("Did fail to tokenize/process card \(failure)")
            completion(.failure(failure))
        }
    }

    // MARK: - Tokenization Utils

    private func createCardTokenizationRequest(with startedState: State.Started) -> POCardTokenizationRequest {
        POCardTokenizationRequest(
            number: cardNumberFormatter.normalized(number: startedState.number.value),
            expMonth: cardExpirationFormatter.expirationMonth(from: startedState.expiration.value) ?? 0,
            expYear: cardExpirationFormatter.expirationYear(from: startedState.expiration.value) ?? 0,
            cvc: startedState.cvc.value,
            name: startedState.cardholderName.value,
            contact: convertToContact(addressParameters: startedState.address),
            preferredScheme: startedState.cardInformation.preferredScheme?.rawValue,
            metadata: configuration.metadata
        )
    }

    // MARK: - Card Information

    /// Updates card information with preliminary info and schedules an update with issuer information.
    private func updateCardInformation(in state: inout CardTokenizationInteractorState.Started, cardNumber: String) {
        let partialIin = String(cardNumber.filter(\.isNumber).prefix(Constants.iinLength))
        guard partialIin != state.cardInformation.partialIin else {
            return
        }
        if case .updating(let task) = state.cardInformation.issuerInformation {
            task.cancel() // Cancel scheduled/ongoing updates
        }
        state.cardInformation = .init(
            partialIin: partialIin,
            preliminaryScheme: CardSchemeProvider.shared.scheme(cardNumber: partialIin),
            issuerInformation: nil,
            preferredScheme: nil
        )
        update(cvc: &state.cvc, for: state.cardInformation.preliminaryScheme)
        guard partialIin.count == Constants.iinLength else {
            return
        }
        let issuerInformationUpdateTask = Task {
            try await Task.sleep(seconds: 0.5) // Debounce
            await updateIssuerInformation()
        }
        state.cardInformation.issuerInformation = .updating(task: issuerInformationUpdateTask)
    }

    private func updateIssuerInformation() async {
        guard case .started(let currentState) = state else {
            return
        }
        var newCardInformation: CardTokenizationInteractorState.CardInformation
        do {
            let issuerInformation = try await cardsService.issuerInformation(
                iin: currentState.cardInformation.partialIin
            )
            newCardInformation = createCardInformation(
                with: issuerInformation, iin: currentState.cardInformation.partialIin
            )
        } catch {
            newCardInformation = currentState.cardInformation
            newCardInformation.issuerInformation = nil
            newCardInformation.preferredScheme = nil
        }
        guard !Task.isCancelled else {
            return
        }
        guard case .started(let currentState) = state else {
            logger.debug("Unable to set issuer information in unsupported state \(state).")
            return
        }
        var newState = currentState
        newState.cardInformation = newCardInformation
        update(cvc: &newState.cvc, for: newState.cardInformation.preferredScheme)
        state = .started(newState)
    }

    private func createCardInformation(
        with issuerInformation: POCardIssuerInformation, iin: String
    ) -> CardTokenizationInteractorState.CardInformation {
        var cardInformation = CardTokenizationInteractorState.CardInformation(
            partialIin: iin, issuerInformation: .completed(issuerInformation)
        )
        cardInformation.eligibility = delegate?.cardTokenization(
            evaluateEligibilityWith: .init(iin: iin, issuerInformation: issuerInformation)
        ).eligibility ?? .eligible(schemes: nil)
        let supportedEligibleSchemes = cardInformation.supportedEligibleSchemes ?? []
        if case .eligible = cardInformation.eligibility, supportedEligibleSchemes.isEmpty {
            // Eligible without eligible schemes is treated as non eligible
            cardInformation.eligibility = .notEligible(nil)
        }
        if supportedEligibleSchemes.count > 1,
           let preferredScheme = delegate?.cardTokenization(preferredSchemeWith: issuerInformation) {
            cardInformation.preferredScheme = preferredScheme
        } else {
            cardInformation.preferredScheme = supportedEligibleSchemes.first
        }
        return cardInformation
    }

    // MARK: - Cvc

    private func update(cvc: inout CardTokenizationInteractorState.Parameter, for scheme: POCardScheme?) {
        let formatter = CardSecurityCodeFormatter()
        formatter.scheme = scheme
        cvc.value = formatter.string(from: cvc.value)
        cvc.formatter = formatter
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
        // swiftlint:disable:next line_length identifier_name
        let _parameters: [WritableKeyPath<State.AddressParameters, State.Parameter>: AddressSpecification.Unit.Plain] = [
            \.street1: .street,
            \.street2: .street,
            \.city: .city,
            \.state: .state,
            \.postalCode: .postcode
        ]
        let specification = AddressSpecificationProvider.shared.specification(for: countryCode)
        for (id, unit) in _parameters {
            let shouldCollect = shouldCollect(unit: unit, specification: specification, countryCode: countryCode)
            parameters[keyPath: id].shouldCollect = shouldCollect
        }
        // todo(andrii-vysotskyi): consider setting available values for state.
        parameters.specification = specification
    }

    private func shouldCollect(
        unit: AddressSpecification.Unit.Plain, specification: AddressSpecification, countryCode: String
    ) -> Bool {
        guard specification.units.contains(where: { $0.plain == unit }) else {
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
        @unknown default:
            return true // Collect all possible fields
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
}

// swiftlint:enable type_body_length file_length
