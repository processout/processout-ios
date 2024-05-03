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

final class DefaultNativeAlternativePaymentViewModel: NativeAlternativePaymentViewModel {

    init(interactor: any NativeAlternativePaymentInteractor) {
        self.interactor = interactor
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

    func start() {
        interactor.start()
    }

    // MARK: - Private Nested Types

    private typealias InteractorState = NativeAlternativePaymentInteractorState

    private enum Constants {
        static let maximumCodeLength = 6
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
        case .submitting(let state):
            updateSections(state: state, isSubmitting: true)
            focusedItemId = nil
            updateActions(state: state, isSubmitting: true)
            isCaptured = false
        case .awaitingCapture(let state):
            updateSections(state: state)
            focusedItemId = nil
            updateActions(state: state)
            isCaptured = false
        case .captured(let state):
            updateSections(state: state)
            focusedItemId = nil
            setActions([])
            isCaptured = true
        default:
            break // Ignored
        }
    }

    // MARK: - Sections

    private func updateSectionsWithStartingState() {
        let section = NativeAlternativePaymentViewModelSection(
            id: "starting", isCentered: true, title: nil, items: [.progress], error: nil
        )
        sections = [section]
    }

    private func updateSections(state: InteractorState.Started, isSubmitting: Bool) {
        var sections = [
            createTitleSection(state: state)
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
        setSections(sections.compactMap { $0 })
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
                isCaptured: false,
                isProgressViewHidden: !state.isDelayed
            )
            item = .submitted(submittedItem)
        } else {
            item = .progress
        }
        let section = NativeAlternativePaymentViewModelSection(
            id: "awaiting-capture", isCentered: true, title: nil, items: [item], error: nil
        )
        setSections([section])
    }

    private func updateSections(state: InteractorState.Captured) {
        guard !configuration.skipSuccessScreen else {
            return
        }
        let item = NativeAlternativePaymentViewModelItem.Submitted(
            id: "captured",
            title: state.logoImage == nil ? state.paymentProviderName : nil,
            logoImage: state.logoImage,
            message: String(resource: .NativeAlternativePayment.Success.message),
            image: UIImage(resource: .success),
            isCaptured: true,
            isProgressViewHidden: true
        )
        let section = NativeAlternativePaymentViewModelSection(
            id: "captured", isCentered: false, title: nil, items: [.submitted(item)], error: nil
        )
        setSections([section])
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
        let actions = [
            submitAction(state: state, isLoading: isSubmitting),
            cancelAction(configuration: configuration.cancelAction, isEnabled: !isSubmitting && state.isCancellable)
        ]
        setActions(actions.compactMap { $0 })
    }

    private func updateActions(state: InteractorState.AwaitingCapture) {
        let actions = [
            cancelAction(configuration: configuration.paymentConfirmation.cancelAction, isEnabled: state.isCancellable)
        ]
        setActions(actions.compactMap { $0 })
    }

    private func submitAction(state: InteractorState.Started, isLoading: Bool) -> POActionsContainerActionViewModel? {
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
        configuration: PONativeAlternativePaymentConfiguration.CancelAction?, isEnabled: Bool
    ) -> POActionsContainerActionViewModel? {
        guard let configuration else {
            return nil
        }
        let action = POActionsContainerActionViewModel(
            id: "native-alternative-payment.secondary-button",
            title: configuration.title ?? String(resource: .NativeAlternativePayment.Button.cancel),
            isEnabled: isEnabled,
            isLoading: false,
            isPrimary: false,
            action: { [weak self] in
                self?.interactor.cancel()
            }
        )
        return action
    }

    // MARK: - Utils

    private func setSections(_ newSections: [NativeAlternativePaymentViewModelSection]) {
        let isAnimated = sections.map(\.animationIdentity) != newSections.map(\.animationIdentity)
        withAnimation(isAnimated ? .default : nil) {
            sections = newSections
        }
        sections = newSections
    }

    private func setActions(_ newActions: [POActionsContainerActionViewModel]) {
        let isAnimated = actions.count != newActions.count
        withAnimation(isAnimated ? .default : nil) {
            actions = newActions
        }
        actions = newActions
    }
}

// swiftlint:enable type_body_length file_length
