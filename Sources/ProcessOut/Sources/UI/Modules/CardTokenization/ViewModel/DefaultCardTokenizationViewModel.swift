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

    func submit() {
        interactor.tokenize()
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

    private lazy var cardNumberFormatter = PaymentCardNumberFormatter()
    private lazy var cardExpirationFormatter = CardExpirationFormatter()

    private var inputValuesCache: [InteractorState.ParameterId: State.InputValue]
    private var inputValuesObservations: [AnyObject]

    // MARK: - Private Methods

    private func observeInteractorStateChanges() {
        interactor.didChange = { [weak self] in self?.configureWithInteractorState() }
    }

    private func configureWithInteractorState() {
        switch interactor.state {
        case .idle:
            state = .idle
        case .started(let startedState):
            state = convertToState(startedState: startedState, isEditingAllowed: true)
        case .failure:
            break
        case .tokenizing(let startedState):
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
        let number = State.InputItem(
            placeholder: Text.CardDetails.Number.placeholder,
            value: inputValue(for: startedState.number, isEditingAllowed: isEditingAllowed),
            formatter: cardNumberFormatter,
            isCompact: false,
            keyboard: .asciiCapableNumberPad,
            contentType: .creditCardNumber
        )
        let expiration = State.InputItem(
            placeholder: Text.CardDetails.Expiration.placeholder,
            value: inputValue(for: startedState.expiration, isEditingAllowed: isEditingAllowed),
            formatter: cardExpirationFormatter,
            isCompact: true,
            keyboard: .asciiCapableNumberPad,
            contentType: nil
        )
        let cvc = State.InputItem(
            placeholder: Text.CardDetails.Cvc.placeholder,
            value: inputValue(for: startedState.cvc, isEditingAllowed: isEditingAllowed),
            formatter: nil,
            isCompact: true,
            keyboard: .asciiCapableNumberPad,
            contentType: nil
        )
        let cardholder = State.InputItem(
            placeholder: Text.CardDetails.Cvc.cardholder,
            value: inputValue(for: startedState.cardholderName, isEditingAllowed: isEditingAllowed),
            formatter: nil,
            isCompact: false,
            keyboard: .asciiCapable,
            contentType: .name
        )
        return [.input(number), .input(expiration), .input(cvc), .input(cardholder)]
    }

    private func inputValue(for parameter: InteractorState.Parameter, isEditingAllowed: Bool) -> State.InputValue {
        if let value = inputValuesCache[parameter.id] {
            value.text = parameter.value
            value.isInvalid = !parameter.isValid
            value.isEditingAllowed = isEditingAllowed
            return value
        }
        let value = State.InputValue(
            text: .init(value: parameter.value),
            isInvalid: .init(value: !parameter.isValid),
            isEditingAllowed: .init(value: isEditingAllowed)
        )
        let observer = value.$text.addObserver { [weak self] value in
            self?.interactor.update(parameterId: parameter.id, value: value)
        }
        inputValuesCache[parameter.id] = value
        inputValuesObservations.append(observer)
        return value
    }

    // MARK: - Actions

    private func submitAction(startedState: InteractorState.Started, isSubmitting: Bool) -> State.Action {
        let action = State.Action(
            title: configuration.primaryActionTitle ?? Text.SubmitButton.title,
            isEnabled: startedState.recentErrorMessage == nil,
            isExecuting: isSubmitting,
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
            handler: { [weak self] in
                self?.interactor.cancel()
            }
        )
        return action
    }
}
