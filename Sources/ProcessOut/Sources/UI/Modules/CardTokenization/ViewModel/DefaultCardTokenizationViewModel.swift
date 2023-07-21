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
        inputValuesObservations = []
        super.init(state: .idle)
        observeInteractorStateChanges()
        observeInputChanges()
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

    // MARK: - Private Properties

    private let interactor: any CardTokenizationInteractor

    private lazy var cardNumberFormatter = PaymentCardNumberFormatter()
    private lazy var cardExpirationFormatter = CardExpirationFormatter()

    private lazy var cardNumber: State.InputValue = .empty
    private lazy var cardExpiration: State.InputValue = .empty
    private lazy var cardCvc: State.InputValue = .empty

    private var inputValuesObservations: [AnyObject]

    // MARK: - Private Methods

    private func observeInputChanges() {
        let numberObserver = cardNumber.$text.addObserver { [weak self] value in
            self?.interactor.update(parameterAt: \.number, value: value)
        }
        let expirationObserver = cardNumber.$text.addObserver { [weak self] value in
            self?.interactor.update(parameterAt: \.expiration, value: value)
        }
        let cvcObserver = cardNumber.$text.addObserver { [weak self] value in
            self?.interactor.update(parameterAt: \.cvc, value: value)
        }
        inputValuesObservations = [numberObserver, expirationObserver, cvcObserver]
    }

    private func observeInteractorStateChanges() {
        interactor.didChange = { [weak self] in self?.configureWithInteractorState() }
    }

    private func configureWithInteractorState() {
        switch interactor.state {
        case .idle:
            state = .idle
        case .started(let startedState):
            state = convertToState(startedState: startedState, isSubmitting: false)
        case .failure:
            break // Temporarly ignored
        case .tokenizing(let startedState):
            state = convertToState(startedState: startedState, isSubmitting: true)
        case .tokenized:
            break // Temporarly ignored
        }
    }

    // MARK: - Started State

    private func convertToState(startedState: InteractorState.Started, isSubmitting: Bool) -> State {
        updateInputValues(startedState: startedState, isSubmitting: isSubmitting)
        let titleItem = State.TitleItem(text: Text.title)
        var sections = [
            State.Section(id: .init(id: "title", title: nil), items: [.title(titleItem)])
        ]
        var cardInformationItems = cardInformationInputItems(startedState: startedState)
        if let error = startedState.recentErrorMessage {
            let errorItem = State.ErrorItem(description: error)
            cardInformationItems.append(.error(errorItem))
        }
        let cardInformationSection = State.Section(
            id: .init(id: "card-info", title: Text.CardDetails.title), items: cardInformationItems
        )
        sections.append(cardInformationSection)
        // todo(andrii-vysotskyi): add proper actions
        let startedState = State(
            sections: sections,
            actions: .init(primary: nil, secondary: nil),
            isEditingAllowed: !isSubmitting
        )
        return startedState
    }

    private func cardInformationInputItems(startedState: InteractorState.Started) -> [State.Item] {
        let number = State.InputItem(
            placeholder: Text.CardDetails.Number.placeholder,
            value: cardNumber,
            isLast: false,
            formatter: cardNumberFormatter,
            isCompact: false,
            keyboard: .numberPad
        )
        let expiration = State.InputItem(
            placeholder: Text.CardDetails.Expiration.placeholder,
            value: cardExpiration,
            isLast: false,
            formatter: cardExpirationFormatter,
            isCompact: true,
            keyboard: .numberPad
        )
        let cvc = State.InputItem(
            placeholder: Text.CardDetails.Cvc.placeholder,
            value: cardCvc,
            isLast: true,
            formatter: nil,
            isCompact: true,
            keyboard: .numberPad
        )
        return [.input(number), .input(expiration), .input(cvc)]
    }

    private func updateInputValues(startedState: InteractorState.Started, isSubmitting: Bool) {
        // swiftlint:disable:next line_length
        let update = { (value: inout State.InputValue, path: KeyPath<InteractorState.Started, InteractorState.Parameter?>) in
            let parameter = startedState[keyPath: path]
            value.text = parameter?.value ?? ""
            value.isInvalid = !(parameter?.isValid ?? true)
            value.isEditingAllowed = !isSubmitting
        }
        update(&cardNumber, \.number)
        update(&cardExpiration, \.expiration)
        update(&cardCvc, \.cvc)
    }

    // MARK: -
}

extension CardTokenizationViewModelState.InputValue {

    static var empty: Self {
        Self(text: .init(value: ""), isInvalid: .init(value: false), isEditingAllowed: .init(value: true))
    }
}

extension CardTokenizationViewModelState {

    static var idle: Self {
        Self(sections: [], actions: .init(primary: nil, secondary: nil), isEditingAllowed: false)
    }
}
