//
//  DefaultNativeAlternativePaymentMethodViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.04.2023.
//

import Foundation

// swiftlint:disable type_body_length file_length

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
        isPaymentCancelDisabled = false
        isCaptureCancelDisabled = false
        cancelActionTimers = [:]
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
    private var cancelActionTimers: [AnyHashable: Timer]
    private var isPaymentCancelDisabled: Bool
    private var isCaptureCancelDisabled: Bool

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
            scheduleCancelActionEnabling(
                configuration: configuration.secondaryAction, isDisabled: \.isPaymentCancelDisabled
            )
            state = convertToState(startedState: startedState, isSubmitting: false)
        case .failure(let failure):
            completion?(.failure(failure))
        case .submitting(let startedState):
            state = convertToState(startedState: startedState, isSubmitting: true)
        case .submitted:
            completion?(.success(()))
        case .awaitingCapture(let awaitingCaptureState):
            scheduleCancelActionEnabling(
                configuration: configuration.paymentConfirmationSecondaryAction, isDisabled: \.isCaptureCancelDisabled
            )
            state = convertToState(awaitingCaptureState: awaitingCaptureState)
        case .captured(let capturedState):
            configure(with: capturedState)
        }
        invalidateCancelActionTimersIfNeeded(state: interactor.state)
    }

    private func configureWithStartingState() {
        let sections = [
            State.Section(id: .init(id: nil, header: nil, isTight: false), items: [.loader])
        ]
        let startedState = State.Started(
            sections: sections,
            actions: .init(primary: nil, secondary: nil),
            isEditingAllowed: false,
            isCaptured: false
        )
        state = .started(startedState)
    }

    // swiftlint:disable:next function_body_length
    private func convertToState(startedState: InteractorState.Started, isSubmitting: Bool) -> State {
        let titleItem = State.TitleItem(
            text: configuration.title ?? Text.title(startedState.gateway.displayName)
        )
        var sections = [
            State.Section(id: .init(id: nil, header: nil, isTight: false), items: [.title(titleItem)])
        ]
        let shouldCenterCodeInput = startedState.parameters.count == 1
        for (offset, parameter) in startedState.parameters.enumerated() {
            let value = startedState.values[parameter.key] ?? .init(value: nil, recentErrorMessage: nil)
            var items = createItems(
                parameter: parameter,
                value: value,
                isEditingAllowed: !isSubmitting,
                isLast: offset == startedState.parameters.indices.last,
                shouldCenterCodeInput: shouldCenterCodeInput
            )
            var isCentered = false
            if case .codeInput = items.first, shouldCenterCodeInput {
                isCentered = true
            }
            if let message = value.recentErrorMessage {
                items.append(.error(State.ErrorItem(description: message, isCentered: isCentered)))
            }
            let isTight = items.contains { item in
                if case .radio = item {
                    return true
                }
                return false
            }
            let section = State.Section(
                id: .init(
                    id: parameter.key,
                    header: .init(title: parameter.displayName, isCentered: isCentered),
                    isTight: isTight
                ),
                items: items
            )
            sections.append(section)
        }
        let startedState = State.Started(
            sections: sections,
            actions: .init(
                primary: submitAction(startedState: startedState, isSubmitting: isSubmitting),
                secondary: cancelAction(
                    configuration: configuration.secondaryAction,
                    isEnabled: !isSubmitting && !isPaymentCancelDisabled
                )
            ),
            isEditingAllowed: !isSubmitting,
            isCaptured: false
        )
        return .started(startedState)
    }

    private func convertToState(awaitingCaptureState: InteractorState.AwaitingCapture) -> State {
        let item: State.Item
        if let expectedActionMessage = awaitingCaptureState.actionMessage {
            let submittedItem = State.SubmittedItem(
                title: awaitingCaptureState.logoImage == nil ? awaitingCaptureState.paymentProviderName : nil,
                logoImage: awaitingCaptureState.logoImage,
                message: expectedActionMessage,
                image: awaitingCaptureState.actionImage,
                isCaptured: false
            )
            item = .submitted(submittedItem)
        } else {
            item = .loader
        }
        let secondaryAction = cancelAction(
            configuration: configuration.paymentConfirmationSecondaryAction,
            isEnabled: !isCaptureCancelDisabled
        )
        let startedState = State.Started(
            sections: [
                .init(id: .init(id: nil, header: nil, isTight: false), items: [item])
            ],
            actions: .init(primary: nil, secondary: secondaryAction),
            isEditingAllowed: false,
            isCaptured: false
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
                title: capturedState.logoImage == nil ? capturedState.paymentProviderName : nil,
                logoImage: capturedState.logoImage,
                message: Text.Success.message,
                image: Asset.Images.success.image,
                isCaptured: true
            )
            let startedState = State.Started(
                sections: [
                    .init(id: .init(id: nil, header: nil, isTight: false), items: [.submitted(submittedItem)])
                ],
                actions: .init(primary: nil, secondary: nil),
                isEditingAllowed: false,
                isCaptured: true
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
            accessibilityIdentifier: "native-alternative-payment.primary-button",
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
            accessibilityIdentifier: "native-alternative-payment.secondary-button",
            handler: { [weak self] in
                self?.interactor.cancel()
            }
        )
        return action
    }

    // MARK: - Input Items

    private func createItems(
        parameter: PONativeAlternativePaymentMethodParameter,
        value parameterValue: InteractorState.ParameterValue,
        isEditingAllowed: Bool,
        isLast: Bool,
        shouldCenterCodeInput: Bool
    ) -> [State.Item] {
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
            let inputItem = State.CodeInputItem(
                // swiftlint:disable:next force_unwrapping
                length: parameter.length!, value: inputValue, isCentered: shouldCenterCodeInput
            )
            return [.codeInput(inputItem)]
        case .singleSelect:
            let optionsCount = parameter.availableValues?.count ?? 0
            if optionsCount <= configuration.inlineSingleSelectValuesLimit {
                return createRadioButtonItems(parameter: parameter, value: inputValue)
            }
            return [createPickerItem(parameter: parameter, value: inputValue)]
        default:
            let inputItem = State.InputItem(
                type: parameter.type,
                placeholder: placeholder(for: parameter),
                value: inputValue,
                isLast: isLast,
                formatter: interactor.formatter(type: parameter.type)
            )
            return [.input(inputItem)]
        }
    }

    private func createRadioButtonItems(
        parameter: PONativeAlternativePaymentMethodParameter, value: State.InputValue
    ) -> [State.Item] {
        assert(parameter.type == .singleSelect)
        let items = parameter.availableValues?.map { option in
            let radioItem = State.RadioButtonItem(
                value: option.displayName,
                isSelected: option.value == value.text,
                isInvalid: value.isInvalid,
                select: { [weak self] in
                    self?.interactor.updateValue(option.value, for: parameter.key)
                }
            )
            return State.Item.radio(radioItem)
        }
        return items ?? []
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

    // MARK: - Cancel Actions Enabling

    private func scheduleCancelActionEnabling(
        configuration: PONativeAlternativePaymentMethodConfiguration.SecondaryAction?,
        isDisabled: ReferenceWritableKeyPath<DefaultNativeAlternativePaymentMethodViewModel, Bool>
    ) {
        let timerKey = AnyHashable(isDisabled)
        guard !cancelActionTimers.keys.contains(timerKey),
              case .cancel(_, let interval) = configuration,
              interval > 0 else {
            return
        }
        self[keyPath: isDisabled] = true
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?[keyPath: isDisabled] = false
            self?.configureWithInteractorState()
        }
        cancelActionTimers[timerKey] = timer
    }

    private func invalidateCancelActionTimersIfNeeded(state interactorState: InteractorState) {
        // If interactor is in a sink state timers should be invalidated to ensure that completion
        // won't be called multiple times.
        switch interactorState {
        case .failure, .captured, .submitted:
            break
        default:
            return
        }
        cancelActionTimers.values.forEach { $0.invalidate() }
        cancelActionTimers = [:]
    }
}

// swiftlint:enable type_body_length file_length
