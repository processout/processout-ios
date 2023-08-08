//
//  DefaultCardTokenizationViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.07.2023.
//

import Foundation

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
        case .failure:
            break
        case .tokenizing(let startedState):
            focusedParameterId = nil
            state = convertToState(startedState: startedState, isEditingAllowed: false)
        case .tokenized:
            break // Currently tokenized is a sink state so simply ignored
        }
    }

    // MARK: - Started State

    private func convertToState(startedState: InteractorState.Started, isEditingAllowed: Bool) -> State {
        var sections = [createTitleSection()]
        var cardInformationItems = cardInformationInputItems(
            startedState: startedState, isEditingAllowed: isEditingAllowed
        )
        if let error = startedState.recentErrorMessage {
            let errorItem = State.ErrorItem(description: error)
            cardInformationItems.append(.error(errorItem))
        }
        let cardInformationSection = State.Section(
            id: .init(id: SectionId.cardInformation, title: Text.CardDetails.title), items: cardInformationItems
        )
        sections.append(cardInformationSection)
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
        return State.Section(id: .init(id: SectionId.title, title: nil), items: [.title(item)])
    }

    private func cardInformationInputItems(
        startedState: InteractorState.Started, isEditingAllowed: Bool
    ) -> [State.Item] {
        let submit: () -> Void = { [weak self] in
            self?.onParameterSubmit()
        }
        let number = State.InputItem(
            placeholder: Text.CardDetails.Number.placeholder,
            value: inputValue(for: startedState.number),
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
            value: inputValue(for: startedState.cvc),
            formatter: startedState.cvc.formatter,
            isCompact: true,
            keyboard: .asciiCapableNumberPad,
            contentType: nil,
            submit: submit
        )
        let cardholder = State.InputItem(
            placeholder: Text.CardDetails.Cvc.cardholder,
            value: inputValue(for: startedState.cardholderName),
            formatter: startedState.cardholderName.formatter,
            isCompact: false,
            keyboard: .asciiCapable,
            contentType: .name,
            submit: submit
        )
        return [.input(number), .input(expiration), .input(cvc), .input(cardholder)]
    }

    private func inputValue(for parameter: InteractorState.Parameter) -> State.InputValue {
        if let value = inputValuesCache[parameter.id] {
            value.text = parameter.value
            value.isInvalid = !parameter.isValid
            value.isFocused = focusedParameterId == parameter.id
            return value
        }
        let value = State.InputValue(
            text: .init(value: parameter.value),
            isInvalid: .init(value: !parameter.isValid),
            isFocused: .init(value: focusedParameterId == parameter.id)
        )
        let textObserver = value.$text.addObserver { [weak self] value in
            self?.interactor.update(parameterId: parameter.id, value: value)
        }
        inputValuesObservations.append(textObserver)
        let activityObserver = value.$isFocused.addObserver { [weak self] isActive in
            if isActive {
                self?.focusedParameterId = parameter.id
            } else if self?.focusedParameterId == parameter.id {
                self?.focusedParameterId = nil
            }
        }
        inputValuesObservations.append(activityObserver)
        inputValuesCache[parameter.id] = value
        return value
    }

    private func onParameterSubmit() {
        guard let focusedParameterId, case .started(let startedState) = interactor.state else {
            return
        }
        let parameters = [
            startedState.number, startedState.expiration, startedState.cvc, startedState.cardholderName
        ]
        guard let focusedParameterIndex = parameters.map(\.id).firstIndex(of: focusedParameterId) else {
            return
        }
        if parameters.indices.contains(focusedParameterIndex + 1) {
            self.focusedParameterId = parameters[focusedParameterIndex + 1].id
            configureWithInteractorState()
        } else {
            interactor.tokenize()
        }
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
            accessibilityIdentifier: "card-tokenization.secondary-button",
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
        let paramters = [startedState.number, startedState.expiration, startedState.cvc, startedState.cardholderName]
        guard let invalidParameterIndex = paramters.firstIndex(where: { !$0.isValid }) else {
            return
        }
        focusedParameterId = paramters[invalidParameterIndex].id
    }
}
