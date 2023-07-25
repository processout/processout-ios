//
//  DefaultCardTokenizationViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.07.2023.
//

import Foundation

final class DefaultCardTokenizationViewModel: BaseViewModel<CardTokenizationViewModelState>, CardTokenizationViewModel {

    init(interactor: any CardTokenizationInteractor) {
        self.interactor = interactor
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
            break // todo(andrii-vysotskyi): support tokenized state
        }
    }

    // MARK: - Started State

    private func convertToState(startedState: InteractorState.Started, isEditingAllowed: Bool) -> State {
        let titleItem = State.TitleItem(text: Text.title)
        var sections = [
            State.Section(id: .init(id: SectionId.title, title: nil), items: [.title(titleItem)])
        ]
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
        // todo(andrii-vysotskyi): add proper actions
        let startedState = State(
            sections: sections, isEditingAllowed: isEditingAllowed
        )
        return startedState
    }

    private func cardInformationInputItems(
        startedState: InteractorState.Started, isEditingAllowed: Bool
    ) -> [State.Item] {
        let number = State.InputItem(
            placeholder: Text.CardDetails.Number.placeholder,
            value: inputValue(for: startedState.number, isEditingAllowed: isEditingAllowed),
            formatter: cardNumberFormatter,
            isCompact: false,
            isSecure: false,
            keyboard: .asciiCapableNumberPad,
            contentType: .creditCardNumber
        )
        let expiration = State.InputItem(
            placeholder: Text.CardDetails.Expiration.placeholder,
            value: inputValue(for: startedState.expiration, isEditingAllowed: isEditingAllowed),
            formatter: cardExpirationFormatter,
            isCompact: true,
            isSecure: false,
            keyboard: .asciiCapableNumberPad,
            contentType: nil
        )
        let cvc = State.InputItem(
            placeholder: Text.CardDetails.Cvc.placeholder,
            value: inputValue(for: startedState.cvc, isEditingAllowed: isEditingAllowed),
            formatter: nil,
            isCompact: true,
            isSecure: true,
            keyboard: .asciiCapableNumberPad,
            contentType: nil
        )
        let cardholder = State.InputItem(
            placeholder: Text.CardDetails.Cvc.cardholder,
            value: inputValue(for: startedState.cardholderName, isEditingAllowed: isEditingAllowed),
            formatter: nil,
            isCompact: false,
            isSecure: false,
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

    // MARK: - Tokenized State
}
