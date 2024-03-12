//
//  DefaultNativeAlternativePaymentViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

// swiftlint:disable file_length type_body_length

final class DefaultNativeAlternativePaymentViewModel: NativeAlternativePaymentViewModel {

    init(
        interactor: some NativeAlternativePaymentInteractor,
        configuration: PONativeAlternativePaymentConfiguration,
        completion: ((Result<Void, POFailure>) -> Void)?
    ) {
        self.configuration = configuration
        self.interactor = interactor
        self.completion = completion
        observeChanges(interactor: interactor)
    }

    deinit {
        interactor.cancel()
    }

    // MARK: - NativeAlternativePaymentViewModel

    @Published
    private(set) var sections: [NativeAlternativePaymentViewModelSection] = []

    @Published
    private(set) var actions: [POActionsContainerActionViewModel] = []

    @Published
    var focusedItemId: AnyHashable?

    @Published
    private(set) var isCaptured = false

    // MARK: - Private Nested Types

    private typealias InteractorState = NativeAlternativePaymentInteractorState

    private enum Constants {
        static let captureSuccessCompletionDelay: TimeInterval = 3
        static let maximumCodeLength = 6
    }

    // MARK: - Private Properties

    private let configuration: PONativeAlternativePaymentConfiguration
    private let interactor: any NativeAlternativePaymentInteractor
    private let completion: ((Result<Void, POFailure>) -> Void)?

    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private var cancelActionTimers: [AnyHashable: Timer] = [:]
    private var isPaymentCancelDisabled = false
    private var isCaptureCancelDisabled = false

    // MARK: - Private Methods

    private func observeChanges(interactor: some NativeAlternativePaymentInteractor) {
        interactor.start()
        interactor.didChange = { [weak self] in
            self?.updateWithInteractorState()
        }
    }

    private func updateWithInteractorState() {
        switch interactor.state {
        case .starting:
            updateSectionsWithStartingState()
            focusedItemId = nil
            actions = []
            isCaptured = false
        case .started(let state):
            updateSections(state: state, isSubmitting: false)
            updateFocusedInputId(state: state)
            updateActions(state: state, isSubmitting: false)
            isCaptured = false
        case .failure(let failure):
            completion?(.failure(failure))
        case .submitting(let state):
            updateSections(state: state, isSubmitting: true)
            focusedItemId = nil
            updateActions(state: state, isSubmitting: true)
            isCaptured = false
        case .submitted:
            completion?(.success(()))
        case .awaitingCapture(let state):
            updateSections(state: state)
            focusedItemId = nil
            updateActions(state: state)
            isCaptured = false
        case .captured(let state):
            updateSections(state: state)
            focusedItemId = nil
            actions = []
            isCaptured = true
        default:
            break // Ignored
        }
        invalidateCancelActionTimersIfNeeded(state: interactor.state)
    }

    // MARK: - Sections

    private func updateSectionsWithStartingState() {
        let section = NativeAlternativePaymentViewModelSection(
            id: "starting", isCentered: true, title: nil, items: [.progress], error: nil
        )
        sections = [section]
    }

    private func updateSections(state: InteractorState.Started, isSubmitting: Bool) {
        let titleItem = NativeAlternativePaymentViewModelItem.Title(
            id: "title",
            text: configuration.title ?? String(
                resource: .NativeAlternativePayment.title, replacements: state.gateway.displayName
            )
        )
        var sections = [
            NativeAlternativePaymentViewModelSection(
                id: "title", isCentered: false, title: nil, items: [.title(titleItem)], error: nil
            )
        ]
        for parameter in state.parameters {
            let items = [
                createItem(parameter: parameter, isEnabled: !isSubmitting)
            ]
            var isSectionCentered = false
            if case .codeInput = items.first, state.parameters.count == 1 {
                isSectionCentered = true
            }
            let section = NativeAlternativePaymentViewModelSection(
                id: parameter.specification.key,
                isCentered: isSectionCentered,
                title: parameter.specification.displayName,
                items: items,
                error: parameter.recentErrorMessage
            )
            sections.append(section)
        }
        self.sections = sections
    }

    private func updateSections(state: InteractorState.AwaitingCapture) {
        let item: NativeAlternativePaymentViewModelItem
        if let expectedActionMessage = state.actionMessage {
            let submittedItem = NativeAlternativePaymentViewModelItem.Submitted(
                id: "awaiting-capture",
                title: state.logoImage == nil ? state.paymentProviderName : nil,
                logoImage: state.logoImage,
                message: expectedActionMessage,
                image: state.actionImage,
                isCaptured: false
            )
            item = .submitted(submittedItem)
        } else {
            item = .progress
        }
        let section = NativeAlternativePaymentViewModelSection(
            id: "awaiting-capture", isCentered: true, title: nil, items: [item], error: nil
        )
        sections = [section]
    }

    private func updateSections(state: InteractorState.Captured) {
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
            let item = NativeAlternativePaymentViewModelItem.Submitted(
                id: "captured",
                title: state.logoImage == nil ? state.paymentProviderName : nil,
                logoImage: state.logoImage,
                message: String(resource: .NativeAlternativePayment.Success.message),
                image: UIImage(resource: .success),
                isCaptured: true
            )
            let section = NativeAlternativePaymentViewModelSection(
                id: "captured", isCentered: false, title: nil, items: [.submitted(item)], error: nil
            )
            sections = [section]
        }
    }

    // MARK: - Input Items

    // swiftlint:disable:next function_body_length
    private func createItem(
        parameter: InteractorState.Parameter, isEnabled: Bool
    ) -> NativeAlternativePaymentViewModelItem {
        switch parameter.specification.type {
        case .numeric where (parameter.specification.length ?? .max) <= Constants.maximumCodeLength:
            let codeInputItem = NativeAlternativePaymentViewModelItem.CodeInput(
                id: parameter.specification.key,
                length: parameter.specification.length!, // swiftlint:disable:this force_unwrapping
                value: .init(
                    get: { parameter.value ?? "" },
                    set: { [weak self] newValue in
                        self?.interactor.updateValue(newValue, for: parameter.specification.key)
                    }
                ),
                isInvalid: parameter.recentErrorMessage != nil,
                isEnabled: isEnabled
            )
            return .codeInput(codeInputItem)
        case .singleSelect:
            let optionsCount = parameter.specification.availableValues?.count ?? 0
            let pickerItem = NativeAlternativePaymentViewModelItem.Picker(
                id: parameter.specification.key,
                options: parameter.specification.availableValues?.map { availableValue in
                    .init(id: availableValue.value, title: availableValue.displayName)
                } ?? [],
                selectedOptionId: .init(
                    get: { parameter.value },
                    set: { [weak self] newValue in
                        self?.interactor.updateValue(newValue, for: parameter.specification.key)
                    }
                ),
                isInvalid: parameter.recentErrorMessage != nil,
                preferrsInline: optionsCount <= configuration.inlineSingleSelectValuesLimit
            )
            return .picker(pickerItem)
        default:
            let inputItem = NativeAlternativePaymentViewModelItem.Input(
                id: parameter.specification.key,
                value: .init(
                    get: { parameter.value ?? "" },
                    set: { [weak self] newValue in
                        self?.interactor.updateValue(newValue, for: parameter.specification.key)
                    }
                ),
                placeholder: placeholder(for: parameter.specification),
                isInvalid: parameter.recentErrorMessage != nil,
                isEnabled: isEnabled,
                icon: nil,
                formatter: parameter.formatter,
                keyboard: keyboard(parameterType: parameter.specification.type),
                contentType: contentType(parameterType: parameter.specification.type),
                onSubmit: { [weak self] in
                    self?.submitFocusedInput()
                }
            )
            return .input(inputItem)
        }
    }

    private func contentType(
        parameterType: PONativeAlternativePaymentMethodParameter.ParameterType
    ) -> UITextContentType? {
        let contentTypes: [PONativeAlternativePaymentMethodParameter.ParameterType: UITextContentType] = [
            .email: .emailAddress, .numeric: .oneTimeCode, .phone: .telephoneNumber
        ]
        return contentTypes[parameterType]
    }

    private func keyboard(
        parameterType: PONativeAlternativePaymentMethodParameter.ParameterType
    ) -> UIKeyboardType {
        let keyboardTypes: [PONativeAlternativePaymentMethodParameter.ParameterType: UIKeyboardType] = [
            .text: .asciiCapable, .email: .emailAddress, .numeric: .numberPad, .phone: .phonePad
        ]
        return keyboardTypes[parameterType] ?? .default
    }

    private func placeholder(for parameter: PONativeAlternativePaymentMethodParameter) -> String {
        switch parameter.type {
        case .email:
            return String(resource: .NativeAlternativePayment.Placeholder.email)
        case .phone:
            return String(resource: .NativeAlternativePayment.Placeholder.phone)
        default:
            return ""
        }
    }

    // MARK: - Parameters Submission

    private func submitFocusedInput() {
        guard let focusedItemId else {
            assertionFailure("Unable to identify focused input.")
            return
        }
        guard case .started(let startedState) = interactor.state else {
            return
        }
        let parameterIds = startedState.parameters.map(\.specification.key)
        guard let focusedInputIndex = parameterIds.map(AnyHashable.init).firstIndex(of: focusedItemId) else {
            return
        }
        if parameterIds.indices.contains(focusedInputIndex + 1) {
            self.focusedItemId = parameterIds[focusedInputIndex + 1]
        } else {
            interactor.submit()
        }
    }

    // MARK: - Focus

    private func updateFocusedInputId(state: InteractorState.Started) {
        if state.parameters.map(\.specification.key).map(AnyHashable.init).contains(focusedItemId) {
            return // Abort if there is already focused input
        }
        if let parameter = state.parameters.first(where: { $0.recentErrorMessage != nil }) {
            focusedItemId = parameter.specification.key // Attempt to focus first invalid parameter if available.
        } else {
            focusedItemId = state.parameters.first?.specification.key
        }
    }

    // MARK: - Actions

    private func updateActions(state: InteractorState.Started, isSubmitting: Bool) {
        scheduleCancelActionEnabling(
            configuration: configuration.secondaryAction,
            isDisabled: \.isPaymentCancelDisabled
        )
        let actions = [
            submitAction(state: state, isLoading: isSubmitting),
            cancelAction(
                configuration: configuration.secondaryAction,
                isEnabled: !isSubmitting && !isPaymentCancelDisabled
            )
        ]
        self.actions = actions.compactMap { $0 }
    }

    private func updateActions(state: InteractorState.AwaitingCapture) {
        scheduleCancelActionEnabling(
            configuration: configuration.paymentConfirmationSecondaryAction,
            isDisabled: \.isCaptureCancelDisabled
        )
        let cancelAction = self.cancelAction(
            configuration: configuration.paymentConfirmationSecondaryAction,
            isEnabled: !isCaptureCancelDisabled
        )
        self.actions = [cancelAction].compactMap { $0 }
    }

    private func submitAction(state: InteractorState.Started, isLoading: Bool) -> POActionsContainerActionViewModel {
        let title: String
        if let customTitle = configuration.primaryActionTitle {
            title = customTitle
        } else {
            priceFormatter.currencyCode = state.currencyCode
            // swiftlint:disable:next legacy_objc_type
            if let formattedAmount = priceFormatter.string(from: state.amount as NSDecimalNumber) {
                title = String(resource: .NativeAlternativePayment.Button.submitAmount, replacements: formattedAmount)
            } else {
                title = String(resource: .NativeAlternativePayment.Button.submit)
            }
        }
        let action = POActionsContainerActionViewModel(
            id: "native-alternative-payment.primary-button",
            title: title,
            isEnabled: state.areParametersValid,
            isLoading: isLoading,
            isPrimary: true,
            action: { [weak self] in
                self?.interactor.submit()
            }
        )
        return action
    }

    private func cancelAction(
        configuration: PONativeAlternativePaymentConfiguration.SecondaryAction?, isEnabled: Bool
    ) -> POActionsContainerActionViewModel? {
        guard case let .cancel(title, _) = configuration else {
            return nil
        }
        let action = POActionsContainerActionViewModel(
            id: "native-alternative-payment.secondary-button",
            title: title ?? String(resource: .NativeAlternativePayment.Button.cancel),
            isEnabled: isEnabled,
            isLoading: false,
            isPrimary: false,
            action: { [weak self] in
                self?.interactor.cancel()
            }
        )
        return action
    }

    // MARK: - Cancel Actions Enabling

    private func scheduleCancelActionEnabling(
        configuration: PONativeAlternativePaymentConfiguration.SecondaryAction?,
        isDisabled: ReferenceWritableKeyPath<DefaultNativeAlternativePaymentViewModel, Bool>
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
            self?.updateWithInteractorState()
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

// swiftlint:enable file_length type_body_length
