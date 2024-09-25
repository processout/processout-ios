//
//  DefaultNativeAlternativePaymentViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

// swiftlint:disable type_body_length file_length

final class DefaultNativeAlternativePaymentViewModel: ViewModel {

    init(interactor: any NativeAlternativePaymentInteractor) {
        self.interactor = interactor
        observeChanges(interactor: interactor)
    }

    deinit {
        interactor.cancel()
    }

    // MARK: - NativeAlternativePaymentViewModel

    @AnimatablePublished
    var state: NativeAlternativePaymentViewModelState = .idle

    func start() {
        $state.performWithoutAnimation(interactor.start)
    }

    // MARK: - Private Nested Types

    private typealias InteractorState = NativeAlternativePaymentInteractorState

    private enum Constants {
        static let maximumCodeLength = 6
        static let maximumCompactMessageLength = 150
    }

    // MARK: - Private Properties

    private let interactor: any NativeAlternativePaymentInteractor

    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private var configuration: PONativeAlternativePaymentConfiguration {
        interactor.configuration
    }

    // MARK: - Private Methods

    private func observeChanges(interactor: any Interactor) {
        interactor.didChange = { [weak self] in
            self?.updateWithInteractorState()
        }
        updateWithInteractorState()
    }

    private func updateWithInteractorState() {
        switch interactor.state {
        case .starting:
            updateWithStartingState()
        case .started(let state):
            update(with: state)
        case .submitting(let state):
            update(withSubmittingState: state)
        case .awaitingCapture(let state):
            update(with: state)
        case .captured(let state) where !configuration.skipSuccessScreen:
            update(with: state)
        default:
            break // Ignored
        }
    }

    // MARK: - Starting State

    private func updateWithStartingState() {
        let sections: [NativeAlternativePaymentViewModelSection] = [
            .init(id: "starting", isCentered: true, title: nil, items: [.progress], error: nil)
        ]
        self.state = NativeAlternativePaymentViewModelState(sections: sections, actions: [], isCaptured: false)
    }

    // MARK: - Started State

    private func update(with state: InteractorState.Started) {
        let newState = NativeAlternativePaymentViewModelState(
            sections: createSections(state: state, isSubmitting: false),
            actions: createActions(state: state, isSubmitting: false),
            isCaptured: false,
            focusedItemId: createFocusedInputId(state: state),
            confirmationDialog: nil
        )
        self.state = newState
    }

    private func createSections(
        state: InteractorState.Started, isSubmitting: Bool
    ) -> [NativeAlternativePaymentViewModelSection] {
        var sections = [
            createTitleSection(state: state)
        ]
        for parameter in state.parameters {
            let items = [
                createItem(parameter: parameter)
            ]
            var isSectionCentered = false
            if case .codeInput = items.first, state.parameters.count == 1 {
                isSectionCentered = configuration.shouldHorizontallyCenterCodeInput
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
        return sections.compactMap { $0 }
    }

    private func createActions(
        state: InteractorState.Started, isSubmitting: Bool
    ) -> [POActionsContainerActionViewModel] {
        let actions = [
            submitAction(state: state, isLoading: isSubmitting),
            cancelAction(configuration: configuration.secondaryAction, isEnabled: !isSubmitting && state.isCancellable)
        ]
        return actions.compactMap { $0 }
    }

    private func createTitleSection(state: InteractorState.Started) -> NativeAlternativePaymentViewModelSection? {
        let title = configuration.title
        ?? String(resource: .NativeAlternativePayment.title, replacements: state.gateway.displayName)
        guard !title.isEmpty else {
            return nil
        }
        let item = NativeAlternativePaymentViewModelItem.Title(id: "title", text: title)
        let section = NativeAlternativePaymentViewModelSection(
            id: "title", isCentered: false, title: nil, items: [.title(item)], error: nil
        )
        return section
    }

    private func createFocusedInputId(state: InteractorState.Started) -> AnyHashable? {
        if state.parameters.map(\.specification.key).map(AnyHashable.init).contains(self.state.focusedItemId) {
            return self.state.focusedItemId // Return already focused input
        }
        if let parameter = state.parameters.first(where: { $0.recentErrorMessage != nil }) {
            return parameter.specification.key // Attempt to focus first invalid parameter if available.
        }
        return state.parameters.first?.specification.key
    }

    // MARK: - Submitting State

    private func update(withSubmittingState state: InteractorState.Started) {
        let newState = NativeAlternativePaymentViewModelState(
            sections: createSections(state: state, isSubmitting: true),
            actions: createActions(state: state, isSubmitting: true),
            isCaptured: false,
            focusedItemId: nil,
            confirmationDialog: nil
        )
        self.state = newState
    }

    // MARK: - Awaiting Capture State

    private func update(with state: InteractorState.AwaitingCapture) {
        let newState = NativeAlternativePaymentViewModelState(
            sections: createSections(state: state),
            actions: createActions(state: state),
            isCaptured: false,
            focusedItemId: nil,
            confirmationDialog: nil
        )
        self.state = newState
    }

    private func createSections(state: InteractorState.AwaitingCapture) -> [NativeAlternativePaymentViewModelSection] {
        let item: NativeAlternativePaymentViewModelItem
        if let customerAction = state.customerAction {
            let submittedItem = NativeAlternativePaymentViewModelItem.Submitted(
                id: "awaiting-capture",
                title: state.paymentProvider.image == nil ? state.paymentProvider.name : nil,
                logoImage: state.paymentProvider.image,
                message: customerAction.message,
                isMessageCompact: customerAction.message.count <= Constants.maximumCompactMessageLength,
                image: customerAction.image,
                isCaptured: false,
                isProgressViewHidden: !state.isDelayed
            )
            item = .submitted(submittedItem)
        } else {
            // todo(andrii-vysotskyi): set additional text saying that payment is being processed.
            item = .progress
        }
        let section = NativeAlternativePaymentViewModelSection(
            id: "awaiting-capture", isCentered: true, title: nil, items: [item], error: nil
        )
        return [section]
    }

    private func createActions(state: InteractorState.AwaitingCapture) -> [POActionsContainerActionViewModel] {
        let actions = [
            createConfirmPaymentCaptureAction(state: state),
            cancelAction(
                configuration: configuration.paymentConfirmation.secondaryAction,
                isEnabled: state.isCancellable
            )
        ]
        return actions.compactMap { $0 }
    }

    private func createConfirmPaymentCaptureAction(
        state: InteractorState.AwaitingCapture
    ) -> POActionsContainerActionViewModel? {
        guard state.shouldConfirmCapture else {
            return nil
        }
        let buttonTitle = interactor.configuration.paymentConfirmation.confirmButton?.title
            ?? String(resource: .NativeAlternativePayment.Button.confirmCapture)
        let action = POActionsContainerActionViewModel(
            id: "native-alternative-payment.primary-button",
            title: buttonTitle,
            isEnabled: true,
            isLoading: false,
            isPrimary: true,
            action: { [weak self] in
                self?.interactor.confirmCapture()
            }
        )
        return action
    }

    // MARK: - Captured State

    private func update(with state: InteractorState.Captured) {
        let newState = NativeAlternativePaymentViewModelState(
            sections: createSections(state: state),
            actions: [],
            isCaptured: true,
            focusedItemId: nil,
            confirmationDialog: nil
        )
        self.state = newState
    }

    private func createSections(state: InteractorState.Captured) -> [NativeAlternativePaymentViewModelSection] {
        let item = NativeAlternativePaymentViewModelItem.Submitted(
            id: "captured",
            title: state.paymentProvider.image == nil ? state.paymentProvider.name : nil,
            logoImage: state.paymentProvider.image,
            message: configuration.successMessage ?? String(resource: .NativeAlternativePayment.Success.message),
            isMessageCompact: true,
            image: UIImage(poResource: .success).withRenderingMode(.alwaysTemplate),
            isCaptured: true,
            isProgressViewHidden: true
        )
        let section = NativeAlternativePaymentViewModelSection(
            id: "captured", isCentered: false, title: nil, items: [.submitted(item)], error: nil
        )
        return [section]
    }

    // MARK: - Input Items

    // swiftlint:disable:next function_body_length
    private func createItem(parameter: InteractorState.Parameter) -> NativeAlternativePaymentViewModelItem {
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
                isInvalid: parameter.recentErrorMessage != nil
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
                isEnabled: true,
                icon: nil,
                formatter: parameter.formatter,
                keyboard: keyboard(parameterType: parameter.specification.type),
                contentType: contentType(parameterType: parameter.specification.type),
                submitLabel: .next,
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
        guard let focusedItemId = state.focusedItemId else {
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
            self.state.focusedItemId = parameterIds[focusedInputIndex + 1]
        } else {
            interactor.submit()
        }
    }

    // MARK: - Actions

    private func submitAction(state: InteractorState.Started, isLoading: Bool) -> POActionsContainerActionViewModel? {
        let title: String
        if let customTitle = configuration.primaryActionTitle {
            title = customTitle
        } else {
            priceFormatter.currencyCode = state.invoice.currencyCode
            // swiftlint:disable:next legacy_objc_type
            if let formattedAmount = priceFormatter.string(from: state.invoice.amount as NSDecimalNumber) {
                title = String(resource: .NativeAlternativePayment.Button.submitAmount, replacements: formattedAmount)
            } else {
                title = String(resource: .NativeAlternativePayment.Button.submit)
            }
        }
        guard !title.isEmpty else {
            return nil
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
        guard case let .cancel(title, _, confirmation) = configuration else {
            return nil
        }
        let action = POActionsContainerActionViewModel(
            id: "native-alternative-payment.secondary-button",
            title: title ?? String(resource: .NativeAlternativePayment.Button.cancel),
            isEnabled: isEnabled,
            isLoading: false,
            isPrimary: false,
            action: { [weak self] in
                self?.cancelPayment(confirmationConfiguration: confirmation)
            }
        )
        return action
    }

    // MARK: - Utils

    /// Depending on configuration this method either shows confirmation dialog prior to cancelling payment
    /// or does that immediately.
    private func cancelPayment(confirmationConfiguration: POConfirmationDialogConfiguration?) {
        if let configuration = confirmationConfiguration {
            interactor.didRequestCancelConfirmation()
            state.confirmationDialog = POConfirmationDialog(
                title: configuration.title ?? String(resource: .NativeAlternativePayment.CancelConfirmation.title),
                message: configuration.message,
                primaryButton: .init(
                    // swiftlint:disable:next line_length
                    title: configuration.confirmActionTitle ?? String(resource: .NativeAlternativePayment.CancelConfirmation.confirm),
                    role: .destructive,
                    action: { [weak self] in
                        self?.interactor.cancel()
                    }
                ),
                secondaryButton: .init(
                    // swiftlint:disable:next line_length
                    title: configuration.cancelActionTitle ?? String(resource: .NativeAlternativePayment.CancelConfirmation.cancel),
                    role: .cancel
                )
            )
        } else {
            interactor.cancel()
        }
    }
}

// swiftlint:enable type_body_length file_length
