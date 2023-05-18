//
//  DefaultNativeAlternativePaymentMethodViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.04.2023.
//

import Foundation

// swiftlint:disable:next type_body_length
final class DefaultNativeAlternativePaymentMethodViewModel:
    BaseViewModel<NativeAlternativePaymentMethodViewModelState>, NativeAlternativePaymentMethodViewModel {

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
        shouldDisablePaymentCancelAction = false
        shouldDisableCaptureCancelAction = false
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
    private typealias Text = Strings.NativeAlternativePayment

    private enum Constants {
        static let captureSuccessCompletionDelay: TimeInterval = 3
        static let maximumCodeLength = 6
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

    private var inputValuesCache: [String: State.InputValue]
    private var inputValuesObservations: [AnyObject]

    private var shouldDisablePaymentCancelAction: Bool
    private var shouldDisableCaptureCancelAction: Bool
    private var paymentCancelEnableTimer: Timer?
    private var captureCancelEnableTimer: Timer?

    // MARK: - Private Methods

    private func observeInteractorStateChanges() {
        interactor.didChange = { [weak self] in self?.configureWithInteractorState() }
    }

    private func configureWithInteractorState() {
        switch interactor.state {
        case .idle:
            state = .idle
        case .starting:
            configureWithStartingState()
        case .started(let startedState):
            schedulePaymentCancelEnabling()
            state = convertToState(startedState: startedState, isSubmitting: false)
        case .failure(let failure):
            completion?(.failure(failure))
        case .submitting(let startedState):
            state = convertToState(startedState: startedState, isSubmitting: true)
        case .submitted:
            completion?(.success(()))
        case .awaitingCapture(let awaitingCaptureState):
            scheduleCaptureCancelEnabling()
            state = convertToState(awaitingCaptureState: awaitingCaptureState)
        case .captured(let capturedState):
            configure(with: capturedState)
        }
    }

    private func configureWithStartingState() {
        let sections = [
            State.Section(id: .init(id: nil, title: nil, decoration: .normal), items: [.loader])
        ]
        let startedState = State.Started(
            sections: sections, actions: .init(primary: nil, secondary: nil), isEditingAllowed: false
        )
        state = .started(startedState)
    }

    private func convertToState(startedState: InteractorState.Started, isSubmitting: Bool) -> State {
        let titleItem = State.TitleItem(
            text: configuration.title ?? Text.title(startedState.gatewayDisplayName)
        )
        var sections = [
            State.Section(id: .init(id: nil, title: nil, decoration: nil), items: [.title(titleItem)])
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
                id: .init(id: parameter.key, title: parameter.displayName, decoration: nil), items: items
            )
            sections.append(section)
        }
        let startedState = State.Started(
            sections: sections,
            actions: .init(
                primary: submitAction(startedState: startedState, isSubmitting: isSubmitting),
                secondary: cancelAction(
                    configuration: configuration.secondaryAction,
                    isEnabled: !isSubmitting && !shouldDisablePaymentCancelAction
                )
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
        let secondaryAction = cancelAction(
            configuration: configuration.paymentConfirmationSecondaryAction,
            isEnabled: !shouldDisableCaptureCancelAction
        )
        let startedState = State.Started(
            sections: [
                .init(id: .init(id: nil, title: nil, decoration: .normal), items: [item])
            ],
            actions: .init(primary: nil, secondary: secondaryAction),
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
                message: Text.Success.message,
                logoImage: capturedState.gatewayLogo,
                image: Asset.Images.success.image,
                isCaptured: true
            )
            let startedState = State.Started(
                sections: [
                    .init(id: .init(id: nil, title: nil, decoration: .success), items: [.submitted(submittedItem)])
                ],
                actions: .init(primary: nil, secondary: nil),
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
                title = Text.SubmitButton.title(formattedAmount)
            } else {
                title = Text.SubmitButton.defaultTitle
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

    private func cancelAction(
        configuration: PONativeAlternativePaymentMethodConfiguration.SecondaryAction?, isEnabled: Bool
    ) -> State.Action? {
        guard case let .cancel(title, _) = configuration else {
            return nil
        }
        let action = State.Action(
            title: title ?? Text.CancelButton.title,
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
        let inputValue: State.InputValue
        if let value = inputValuesCache[parameter.key] {
            inputValue = value
            inputValue.text = parameterValue.value ?? ""
            inputValue.isInvalid = parameterValue.recentErrorMessage != nil
            inputValue.isEditingAllowed = isEditingAllowed
        } else {
            inputValue = State.InputValue(
                text: .init(value: parameterValue.value ?? ""),
                isInvalid: .init(value: parameterValue.recentErrorMessage != nil),
                isEditingAllowed: .init(value: isEditingAllowed)
            )
            inputValuesCache[parameter.key] = inputValue
            let observer = inputValue.$text.addObserver { [weak self] updatedValue in
                self?.interactor.updateValue(updatedValue, for: parameter.key)
            }
            inputValuesObservations.append(observer)
        }
        switch parameter.type {
        case .numeric where (parameter.length ?? .max) <= Constants.maximumCodeLength:
            // swiftlint:disable:next force_unwrapping
            let inputItem = State.CodeInputItem(length: parameter.length!, value: inputValue)
            return .codeInput(inputItem)
        case .singleSelect:
            return createPickerItem(parameter: parameter, value: inputValue)
        default:
            let inputItem = State.InputItem(
                type: parameter.type,
                placeholder: placeholder(for: parameter),
                value: inputValue,
                isLast: isLast,
                formatter: interactor.formatter(type: parameter.type)
            )
            return .input(inputItem)
        }
    }

    private func createPickerItem(
        parameter: PONativeAlternativePaymentMethodParameter, value: State.InputValue
    ) -> State.Item {
        assert(parameter.type == .singleSelect)
        let options = parameter.availableValues?.map { option in
            State.PickerOption(name: option.displayName, isSelected: option.value == value.text) { [weak self] in
                self?.interactor.updateValue(option.value, for: parameter.key)
            }
        }
        let item = State.PickerItem(
            // Value of single select parameter is not user friendly instead display name should be used.
            value: parameter.availableValues?.first { $0.value == value.text }?.displayName ?? "",
            isInvalid: value.isInvalid,
            options: options ?? []
        )
        return .picker(item)
    }

    private func placeholder(for parameter: PONativeAlternativePaymentMethodParameter) -> String? {
        switch parameter.type {
        case .numeric, .text, .singleSelect:
            return nil
        case .email:
            return Text.Email.placeholder
        case .phone:
            return Text.Phone.placeholder
        }
    }

    // MARK: -

    private func schedulePaymentCancelEnabling() {
        guard paymentCancelEnableTimer == nil,
              case .cancel(_, let interval) = configuration.secondaryAction,
              interval > 0 else {
            return
        }
        shouldDisablePaymentCancelAction = true
        paymentCancelEnableTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.shouldDisablePaymentCancelAction = false
            self?.configureWithInteractorState()
        }
    }

    private func scheduleCaptureCancelEnabling() {
        guard captureCancelEnableTimer == nil,
              case .cancel(_, let interval) = configuration.paymentConfirmationSecondaryAction,
              interval > 0 else {
            return
        }
        shouldDisableCaptureCancelAction = true
        captureCancelEnableTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.shouldDisableCaptureCancelAction = false
            self?.configureWithInteractorState()
        }
    }
}
