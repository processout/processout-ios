//
//  DefaultBetaNativeAlternativePaymentMethodViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.04.2023.
//

import Foundation

final class DefaultBetaNativeAlternativePaymentMethodViewModel:
    BaseViewModel<BetaNativeAlternativePaymentMethodViewModelState>, BetaNativeAlternativePaymentMethodViewModel {

    init(
        interactor: any NativeAlternativePaymentMethodInteractor,
        configuration: PONativeAlternativePaymentMethodConfiguration,
        completion: ((Result<Void, POFailure>) -> Void)?
    ) {
        self.interactor = interactor
        self.configuration = configuration
        self.completion = completion
        inputValuesObservations = []
        inputValuesCache = [:]
        super.init(state: .idle)
        observeInteractorStateChanges()
    }

    override func start() {
        interactor.start()
    }

    func submit() {
        interactor.submit()
    }

    // MARK: - Private Nested Types

    private typealias InteractorState = NativeAlternativePaymentMethodInteractorState
    private typealias Strings = ProcessOut.Strings.NativeAlternativePayment

    private enum Constants {
        static let captureSuccessCompletionDelay: TimeInterval = 3
        static let maximumCodeLength = 6
    }

    private struct InputValue {

        /// Indicates whether parameter is invalid.
        @ReferenceWrapper
        var isInvalid: Bool

        /// Current parameter's value. This value won't be modified by view model.
        @ReferenceWrapper
        var value: String
    }

    // MARK: - NativeAlternativePaymentMethodInteractor

    private let interactor: any NativeAlternativePaymentMethodInteractor
    private let configuration: PONativeAlternativePaymentMethodConfiguration
    private let completion: ((Result<Void, POFailure>) -> Void)?

    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private var inputValuesCache: [String: InputValue]
    private var inputValuesObservations: [AnyObject]

    // MARK: - Private Methods

    private func observeInteractorStateChanges() {
        interactor.didChange = { [weak self] in self?.configureWithInteractorState() }
    }

    private func configureWithInteractorState() {
        switch interactor.state {
        case .idle:
            state = .idle
        case .starting:
            let sections = [
                State.Section(id: .init(id: nil, title: nil), items: [.loader])
            ]
            let startedState = State.Started(sections: sections, actions: nil, isEditingAllowed: false)
            state = .started(startedState)
        case .started(let startedState):
            state = convertToState(startedState: startedState, isSubmitting: false)
        case .failure(let failure):
            completion?(.failure(failure))
        case .submitting(let startedState):
            state = convertToState(startedState: startedState, isSubmitting: true)
        case .submitted:
            completion?(.success(()))
        case .awaitingCapture(let awaitingCaptureState):
            state = convertToState(awaitingCaptureState: awaitingCaptureState)
        case .captured(let capturedState):
            configure(with: capturedState)
        }
    }

    private func convertToState(startedState: InteractorState.Started, isSubmitting: Bool) -> State {
        let titleItem = State.TitleItem(
            text: configuration.title ?? Strings.title(startedState.gatewayDisplayName)
        )
        var sections = [
            State.Section(id: .init(id: nil, title: nil), items: [.title(titleItem)])
        ]
        for (offset, parameter) in startedState.parameters.enumerated() {
            let value = startedState.values[parameter.key] ?? .init(value: nil, recentErrorMessage: nil)
            var items = [
                createItem(
                    parameter: parameter,
                    value: value,
                    isEditingAllowed: !isSubmitting,
                    isLast: offset == startedState.parameters.indices.last
                )
            ]
            if let message = value.recentErrorMessage {
                items.append(.error(State.ErrorItem(description: message)))
            }
            let section = State.Section(
                id: .init(id: parameter.key, title: parameter.displayName), items: items
            )
            sections.append(section)
        }
        let startedState = State.Started(
            sections: sections,
            actions: .init(
                primary: submitAction(startedState: startedState, isSubmitting: isSubmitting),
                secondary: cancelAction(isEnabled: !isSubmitting)
            ),
            isEditingAllowed: !isSubmitting
        )
        return .started(startedState)
    }

    private func convertToState(awaitingCaptureState: InteractorState.AwaitingCapture) -> State {
        let item: State.Item
        if let expectedActionMessage = awaitingCaptureState.expectedActionMessage {
            let submittedItem = State.SubmittedItem(
                message: expectedActionMessage,
                logoImage: awaitingCaptureState.gatewayLogoImage,
                image: awaitingCaptureState.actionImage,
                isCaptured: false
            )
            item = .submitted(submittedItem)
        } else {
            item = .loader
        }
        let startedState = State.Started(
            sections: [
                .init(id: .init(id: nil, title: nil), items: [item])
            ],
            actions: nil,
            isEditingAllowed: false
        )
        return .started(startedState)
    }

    private func configure(with capturedState: InteractorState.Captured) {
        if configuration.skipSuccessScreen {
            completion?(.success(()))
        } else {
            Timer.scheduledTimer(
                withTimeInterval: Constants.captureSuccessCompletionDelay,
                repeats: false,
                block: { [weak self] _ in
                    self?.completion?(.success(()))
                }
            )
            let submittedItem = State.SubmittedItem(
                message: Strings.Success.message,
                logoImage: capturedState.gatewayLogo,
                image: Asset.Images.success.image,
                isCaptured: true
            )
            let startedState = State.Started(
                sections: [
                    .init(id: .init(id: nil, title: nil), items: [.submitted(submittedItem)])
                ],
                actions: nil,
                isEditingAllowed: false
            )
            state = .started(startedState)
        }
    }

    // MARK: - Actions

    private func submitAction(startedState: InteractorState.Started, isSubmitting: Bool) -> State.Action {
        let title: String
        if let customTitle = configuration.primaryActionTitle {
            title = customTitle
        } else {
            priceFormatter.currencyCode = startedState.currencyCode
            // swiftlint:disable:next legacy_objc_type
            if let formattedAmount = priceFormatter.string(from: startedState.amount as NSDecimalNumber) {
                title = Strings.SubmitButton.title(formattedAmount)
            } else {
                title = Strings.SubmitButton.defaultTitle
            }
        }
        let action = State.Action(
            title: title,
            isEnabled: startedState.isSubmitAllowed,
            isExecuting: isSubmitting,
            handler: { [weak self] in
                self?.interactor.submit()
            }
        )
        return action
    }

    private func cancelAction(isEnabled: Bool) -> State.Action? {
        guard case let .cancel(title) = configuration.secondaryAction else {
            return nil
        }
        let action = State.Action(
            title: title ?? Strings.CancelButton.title,
            isEnabled: isEnabled,
            isExecuting: false,
            handler: { [weak self] in
                self?.interactor.cancel()
            }
        )
        return action
    }

    // MARK: - Input Items

    private func createItem(
        parameter: PONativeAlternativePaymentMethodParameter,
        value parameterValue: InteractorState.ParameterValue,
        isEditingAllowed: Bool,
        isLast: Bool
    ) -> State.Item {
        let inputValue: InputValue
        if let value = inputValuesCache[parameter.key] {
            inputValue = value
            inputValue.value = parameterValue.value ?? ""
            inputValue.isInvalid = parameterValue.recentErrorMessage != nil
        } else {
            inputValue = InputValue(
                isInvalid: .init(value: parameterValue.recentErrorMessage != nil),
                value: .init(value: parameterValue.value ?? "")
            )
            inputValuesCache[parameter.key] = inputValue
            let observer = inputValue.$value.addObserver { [weak self] updatedValue in
                self?.interactor.updateValue(updatedValue, for: parameter.key)
            }
            inputValuesObservations.append(observer)
        }
        switch parameter.type {
        case .numeric where (parameter.length ?? .max) <= Constants.maximumCodeLength:
            let inputItem = State.CodeInputItem(
                length: parameter.length!, // swiftlint:disable:this force_unwrapping
                isInvalid: inputValue.$isInvalid,
                value: inputValue.$value,
                isEditingAllowed: isEditingAllowed
            )
            return .codeInput(inputItem)
        default:
            let inputItem = State.InputItem(
                type: parameter.type,
                placeholder: placeholder(for: parameter),
                isInvalid: inputValue.$isInvalid,
                value: inputValue.$value,
                isEditingAllowed: isEditingAllowed,
                isLast: isLast,
                formatted: { [weak self] value in
                    self?.interactor.formatted(value: value, type: parameter.type) ?? ""
                }
            )
            return .input(inputItem)
        }
    }

    private func placeholder(for parameter: PONativeAlternativePaymentMethodParameter) -> String? {
        switch parameter.type {
        case .numeric, .text:
            return nil
        case .email:
            return Strings.Email.placeholder
        case .phone:
            return Strings.Phone.placeholder
        }
    }
}
