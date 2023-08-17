//
//  DefaultCardTokenizationViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.07.2023.
//

import Foundation
import UIKit

// swiftlint:disable:next type_body_length
final class DefaultCardTokenizationViewModel: BaseViewModel<CardTokenizationViewModelState>, CardTokenizationViewModel {

    init(interactor: any CardTokenizationInteractor, configuration: POCardTokenizationConfiguration) {
        self.interactor = interactor
        self.configuration = configuration
        inputValuesCache = [:]
        inputValuesObservations = []
        super.init(state: .idle)
        observeInteractorStateChanges()
    }

    override func start() {
        interactor.start()
    }

    func didAppear() {
        focusedParameterId = \.number
        configureWithInteractorState()
    }

    // MARK: - Private Nested Types

    private typealias InteractorState = CardTokenizationInteractorState
    private typealias Text = Strings.CardTokenization

    private enum SectionId {
        static let title = "title"
        static let cardInformation = "card-info"
        static let preferredScheme = "preferred-scheme"
    }

    // MARK: - Private Properties

    private let interactor: any CardTokenizationInteractor
    private let configuration: POCardTokenizationConfiguration

    private var inputValuesCache: [InteractorState.ParameterId: State.InputValue]
    private var inputValuesObservations: [AnyObject]

    /// Changes to this property are not automatically propagated to view. Instead
    /// `configureWithInteractorState` method should be called directly.
    private var focusedParameterId: InteractorState.ParameterId?

    // MARK: - Private Methods

    private func observeInteractorStateChanges() {
        interactor.didChange = { [weak self] in self?.configureWithInteractorState() }
    }

    private func configureWithInteractorState() {
        switch interactor.state {
        case .idle:
            state = .idle
        case .started(let startedState):
            configureFocusedParameter(startedState: startedState)
            state = convertToState(startedState: startedState, isEditingAllowed: true)
        case .tokenizing(let startedState):
            focusedParameterId = nil
            state = convertToState(startedState: startedState, isEditingAllowed: false)
        case .tokenized, .failure:
            break
        }
    }

    // MARK: - Started State

    private func convertToState(startedState: InteractorState.Started, isEditingAllowed: Bool) -> State {
        var cardInformationItems = cardInformationInputItems(
            startedState: startedState
        )
        if let error = startedState.recentErrorMessage {
            let errorItem = State.ErrorItem(description: error, isCentered: false)
            cardInformationItems.append(.error(errorItem))
        }
        let cardInformationSection = State.Section(
            id: .init(
                id: SectionId.cardInformation,
                header: .init(title: Text.CardDetails.title, isCentered: false),
                isTight: false
            ),
            items: cardInformationItems
        )
        let sections = [
            createTitleSection(),
            cardInformationSection,
            preferredSchemeSection(startedState: startedState)
        ]
        let startedState = State(
            sections: sections.compactMap { $0 },
            actions: .init(
                primary: submitAction(startedState: startedState, isSubmitting: !isEditingAllowed),
                secondary: cancelAction(isEnabled: isEditingAllowed)
            ),
            isEditingAllowed: isEditingAllowed
        )
        return startedState
    }

    private func createTitleSection() -> State.Section? {
        let title = configuration.title ?? Text.title
        guard !title.isEmpty else {
            return nil
        }
        let item = State.TitleItem(text: Text.title)
        return State.Section(id: .init(id: SectionId.title, header: nil, isTight: false), items: [.title(item)])
    }

    private func cardInformationInputItems(startedState: InteractorState.Started) -> [State.Item] {
        let submit: () -> Void = { [weak self] in
            self?.onParameterSubmit()
        }
        let number = State.InputItem(
            placeholder: Text.CardDetails.Number.placeholder,
            value: inputValue(for: startedState.number, icon: cardNumberIcon(startedState: startedState)),
            formatter: startedState.number.formatter,
            isCompact: false,
            keyboard: .asciiCapableNumberPad,
            contentType: .creditCardNumber,
            submit: submit
        )
        let expiration = State.InputItem(
            placeholder: Text.CardDetails.Expiration.placeholder,
            value: inputValue(for: startedState.expiration),
            formatter: startedState.expiration.formatter,
            isCompact: true,
            keyboard: .asciiCapableNumberPad,
            contentType: nil,
            submit: submit
        )
        let cvc = State.InputItem(
            placeholder: Text.CardDetails.Cvc.placeholder,
            value: inputValue(for: startedState.cvc, icon: Asset.Images.cardBack.image),
            formatter: startedState.cvc.formatter,
            isCompact: true,
            keyboard: .asciiCapableNumberPad,
            contentType: nil,
            submit: submit
        )
        let items = [.input(number), .input(expiration), .input(cvc), cardholderInputItem(startedState: startedState)]
        return items.compactMap { $0 }
    }

    private func cardholderInputItem(startedState: InteractorState.Started) -> State.Item? {
        guard configuration.isCardholderNameInputVisible else {
            return nil
        }
        let inputItem = State.InputItem(
            placeholder: Text.CardDetails.Cvc.cardholder,
            value: inputValue(for: startedState.cardholderName),
            formatter: startedState.cardholderName.formatter,
            isCompact: false,
            keyboard: .asciiCapable,
            contentType: .name,
            submit: { [weak self] in
                self?.onParameterSubmit()
            }
        )
        return .input(inputItem)
    }

    private func inputValue(for parameter: InteractorState.Parameter, icon: UIImage? = nil) -> State.InputValue {
        let value: State.InputValue
        if let cachedValue = inputValuesCache[parameter.id] {
            value = cachedValue
        } else {
            value = State.InputValue()
            inputValuesCache[parameter.id] = value
            observeChanges(value: value, parameter: parameter)
        }
        value.text = parameter.value
        value.isInvalid = !parameter.isValid
        value.isFocused = focusedParameterId == parameter.id
        value.icon = icon
        return value
    }

    private func observeChanges(value: State.InputValue, parameter: InteractorState.Parameter) {
        let textObserver = value.$text.addObserver { [weak self] value in
            self?.interactor.update(parameterId: parameter.id, value: value)
        }
        let activityObserver = value.$isFocused.addObserver { [weak self] isActive in
            if isActive {
                self?.focusedParameterId = parameter.id
            } else if self?.focusedParameterId == parameter.id {
                self?.focusedParameterId = nil
            }
        }
        inputValuesObservations.append(textObserver)
        inputValuesObservations.append(activityObserver)
    }

    private func onParameterSubmit() {
        guard let focusedParameterId, case .started(let startedState) = interactor.state else {
            return
        }
        let parameterIds = parameters(startedState: startedState).map(\.id)
        guard let focusedParameterIndex = parameterIds.firstIndex(of: focusedParameterId) else {
            return
        }
        if parameterIds.indices.contains(focusedParameterIndex + 1) {
            self.focusedParameterId = parameterIds[focusedParameterIndex + 1]
            configureWithInteractorState()
        } else {
            interactor.tokenize()
        }
    }

    private func cardNumberIcon(startedState: InteractorState.Started) -> UIImage? {
        let scheme = startedState.issuerInformation?.coScheme != nil
            ? startedState.preferredScheme
            : startedState.issuerInformation?.scheme
        guard let scheme else {
            return nil
        }
        // todo(andrii-vysotskyi): support more schemes
        let assets = [
            "visa": Asset.Images.visa,
            "mastercard": Asset.Images.mastercard,
            "american express": Asset.Images.amex,
            "china union pay": Asset.Images.unionPay,
            "discover": Asset.Images.discover
        ]
        let normalizedScheme = scheme.lowercased()
        return assets[normalizedScheme]?.image
    }

    private func preferredSchemeSection(startedState: InteractorState.Started) -> State.Section? {
        guard configuration.isSchemeSelectionAllowed,
              let issuerInformation = startedState.issuerInformation,
              let coScheme = issuerInformation.coScheme else {
            return nil
        }
        let sectionId = State.SectionIdentifier(
            id: SectionId.preferredScheme,
            header: .init(title: Text.PreferredScheme.title, isCentered: false),
            isTight: true
        )
        let schemeItem = State.RadioButtonItem(
            value: Text.PreferredScheme.description(issuerInformation.scheme.capitalized),
            isSelected: startedState.preferredScheme == issuerInformation.scheme,
            isInvalid: false,
            accessibilityIdentifier: "card-tokenization.scheme-button",
            select: { [weak self] in
                self?.interactor.setPreferredScheme(issuerInformation.scheme)
            }
        )
        let coSchemeItem = State.RadioButtonItem(
            value: Text.PreferredScheme.description(coScheme.capitalized),
            isSelected: startedState.preferredScheme == coScheme,
            isInvalid: false,
            accessibilityIdentifier: "card-tokenization.co-scheme-button",
            select: { [weak self] in
                self?.interactor.setPreferredScheme(coScheme)
            }
        )
        let items = [schemeItem, coSchemeItem].map(State.Item.radio)
        return State.Section(id: sectionId, items: items)
    }

    // MARK: - Actions

    private func submitAction(startedState: InteractorState.Started, isSubmitting: Bool) -> State.Action {
        let action = State.Action(
            title: configuration.primaryActionTitle ?? Text.SubmitButton.title,
            isEnabled: startedState.recentErrorMessage == nil,
            isExecuting: isSubmitting,
            accessibilityIdentifier: "card-tokenization.primary-button",
            handler: { [weak self] in
                self?.interactor.tokenize()
            }
        )
        return action
    }

    private func cancelAction(isEnabled: Bool) -> State.Action? {
        let title = configuration.cancelActionTitle ?? Text.CancelButton.title
        guard !title.isEmpty else {
            return nil
        }
        let action = State.Action(
            title: title,
            isEnabled: isEnabled,
            isExecuting: false,
            accessibilityIdentifier: "card-tokenization.cancel-button",
            handler: { [weak self] in
                self?.interactor.cancel()
            }
        )
        return action
    }

    // MARK: - Utils

    private func configureFocusedParameter(startedState: InteractorState.Started) {
        guard focusedParameterId == nil else {
            return
        }
        let paramters = parameters(startedState: startedState)
        guard let invalidParameterIndex = paramters.firstIndex(where: { !$0.isValid }) else {
            return
        }
        focusedParameterId = paramters[invalidParameterIndex].id
    }

    private func parameters(startedState: InteractorState.Started) -> [InteractorState.Parameter] {
        var parameters = [startedState.number, startedState.expiration, startedState.cvc]
        if configuration.isCardholderNameInputVisible {
            parameters.append(startedState.cardholderName)
        }
        return parameters
    }
}
