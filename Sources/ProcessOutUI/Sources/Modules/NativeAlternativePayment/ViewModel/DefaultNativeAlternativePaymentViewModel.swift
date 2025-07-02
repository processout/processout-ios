//
//  DefaultNativeAlternativePaymentViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import Photos
import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

// swiftlint:disable type_body_length file_length

@available(iOS 14, *)
final class DefaultNativeAlternativePaymentViewModel: ViewModel {

    init(interactor: any NativeAlternativePaymentInteractor) {
        self.interactor = interactor
        observeChanges(interactor: interactor)
    }

    deinit {
        Task { @MainActor [interactor] in interactor.cancel() }
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
    }

    // MARK: - Private Properties

    private let interactor: any NativeAlternativePaymentInteractor

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
            update(withSubmittingState: state.snapshot)
        case .awaitingRedirect(let state):
            update(with: state)
        case .redirecting(let state):
            update(with: state)
        case .awaitingCompletion(let state):
            update(with: state)
        case .completed(let state) where configuration.success != nil:
            update(with: state)
        default:
            break // Ignored
        }
    }

    // MARK: - Starting State

    private func updateWithStartingState() {
        let items: [NativeAlternativePaymentViewModelItem] = [.progress]
        self.state = NativeAlternativePaymentViewModelState(items: items)
    }

    // MARK: - Started State

    private func update(with state: InteractorState.Started) {
        let newState = NativeAlternativePaymentViewModelState(
            items: createItems(state: state, isSubmitting: false),
            focusedItemId: createFocusedInputId(state: state),
            confirmationDialog: nil
        )
        self.state = newState
    }

    private func createItems(
        state: InteractorState.Started, isSubmitting: Bool
    ) -> [NativeAlternativePaymentViewModelItem] {
        var items = [
            createTitleItem(paymentMethod: state.paymentMethod)
        ]
        items += createItems(for: state.elements, state: state)
        items.append(
            createControlGroupItem(state: state, isSubmitting: isSubmitting)
        )
        return items.compactMap { $0 }
    }

    private func createControlGroupItem(
        state: InteractorState.Started, isSubmitting: Bool
    ) -> NativeAlternativePaymentViewModelItem {
        let buttons = [
            createSubmitButton(state: state, isLoading: isSubmitting),
            createCancelButton(
                configuration: configuration.cancelButton,
                isEnabled: !isSubmitting && state.isCancellable
            )
        ].compactMap { $0 }
        let controlGroup = NativeAlternativePaymentViewModelItem.ControlGroup(id: "control-group", content: buttons)
        return .controlGroup(controlGroup)
    }

    private func createFocusedInputId(state: InteractorState.Started) -> AnyHashable? {
        if state.parameters.values.map(\.specification.key).map(AnyHashable.init).contains(self.state.focusedItemId) {
            return self.state.focusedItemId // Return already focused input
        }
        if let parameter = state.parameters.values.first(where: { $0.recentErrorMessage != nil }) {
            return parameter.specification.key // Attempt to focus first invalid parameter if available.
        }
        for element in state.elements {
            if case .form(let form) = element {
                return form.parameters.parameterDefinitions.first?.key
            }
        }
        return nil
    }

    // MARK: - Submitting State

    private func update(withSubmittingState state: InteractorState.Started) {
        let newState = NativeAlternativePaymentViewModelState(
            items: createItems(state: state, isSubmitting: true),
            focusedItemId: nil,
            confirmationDialog: nil
        )
        self.state = newState
    }

    // MARK: - Awaiting Capture State

    private func update(with state: InteractorState.AwaitingCompletion) {
        let newState = NativeAlternativePaymentViewModelState(
            items: createItems(state: state),
            focusedItemId: nil,
            confirmationDialog: nil
        )
        self.state = newState
    }

    private func createItems(
        state: InteractorState.AwaitingCompletion
    ) -> [NativeAlternativePaymentViewModelItem] {
        var items: [NativeAlternativePaymentViewModelItem?] = [
            createTitleItem(paymentMethod: state.paymentMethod)
        ]
        if state.shouldConfirmPayment {
            items.append(
                contentsOf: createItems(for: state.elements, state: nil)
            )
        } else if let estimatedCompletionDate = state.estimatedCompletionDate {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = [.pad]
            let confirmationProgressItem = NativeAlternativePaymentViewModelItem.ConfirmationProgress(
                firstStepTitle: String(
                    resource: .NativeAlternativePayment.PaymentConfirmation.Progress.FirstStep.title
                ),
                secondStepTitle: String(
                    resource: .NativeAlternativePayment.PaymentConfirmation.Progress.SecondStep.title
                ),
                secondStepDescription: { remainingDuration in
                    String(
                        resource: .NativeAlternativePayment.PaymentConfirmation.Progress.SecondStep.description,
                        replacements: remainingDuration
                    )
                },
                formatter: formatter,
                estimatedCompletionDate: estimatedCompletionDate
            )
            items.append(.confirmationProgress(confirmationProgressItem))
        }
        items.append(createControlGroupItem(state: state))
        return items.compactMap { $0 }
    }

    private func createControlGroupItem(
        state: InteractorState.AwaitingCompletion
    ) -> NativeAlternativePaymentViewModelItem {
        let buttons = [
            createConfirmPaymentButton(state: state),
            createCancelButton(
                configuration: configuration.paymentConfirmation.cancelButton,
                isEnabled: state.isCancellable
            )
        ].compactMap { $0 }
        let controlGroup = NativeAlternativePaymentViewModelItem.ControlGroup(id: "control-group", content: buttons)
        return .controlGroup(controlGroup)
    }

    private func createConfirmPaymentButton(state: InteractorState.AwaitingCompletion) -> POButtonViewModel? {
        guard state.shouldConfirmPayment else {
            return nil
        }
        guard let buttonConfiguration = interactor.configuration.paymentConfirmation.confirmButton else {
            assertionFailure("Unable to setup confirmation UI without confirm button configuration.")
            return nil
        }
        let action = POButtonViewModel(
            id: "primary-button",
            title: buttonConfiguration.title ?? String(resource: .NativeAlternativePayment.Button.confirmPayment),
            icon: buttonConfiguration.icon,
            role: .primary,
            action: { [weak self] in
                self?.interactor.confirmPayment()
            }
        )
        return action
    }

    private func saveImageToPhotoLibraryOrShowError(_ image: UIImage) {
        Task { @MainActor in
            let barcodeInteraction = interactor.configuration.barcodeInteraction
            if await saveImageToPhotoLibrary(image) {
                if barcodeInteraction.generateHapticFeedback {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            } else if let configuration = barcodeInteraction.saveErrorConfirmation {
                let dialog = POConfirmationDialog(
                    title: configuration.title ?? String(resource: .NativeAlternativePayment.BarcodeError.title),
                    message: configuration.message ?? String(resource: .NativeAlternativePayment.BarcodeError.message),
                    primaryButton: .init(
                        // swiftlint:disable:next line_length
                        title: configuration.confirmActionTitle ?? String(resource: .NativeAlternativePayment.BarcodeError.confirm)
                    )
                )
                self.state.confirmationDialog = dialog
            }
        }
    }

    // MARK: - Redirect

    private func update(with state: InteractorState.AwaitingRedirect, isRedirecting: Bool = false) {
        var items: [NativeAlternativePaymentViewModelItem?] = [
            createTitleItem(paymentMethod: state.paymentMethod)
        ]
        items.append(
            contentsOf: createItems(for: state.elements, state: nil)
        )
        items.append(
            createControlGroupItem(state: state, isRedirecting: isRedirecting)
        )
        let newState = NativeAlternativePaymentViewModelState(
            items: items.compactMap { $0 }, focusedItemId: nil, confirmationDialog: nil
        )
        self.state = newState
    }

    private func createControlGroupItem(
        state: InteractorState.AwaitingRedirect, isRedirecting: Bool
    ) -> NativeAlternativePaymentViewModelItem {
        var buttons: [POButtonViewModel] = [
            createRedirectButton(state: state, isRedirecting: isRedirecting)
        ]
        let cancelButton = createCancelButton(
            configuration: interactor.configuration.cancelButton, isEnabled: state.isCancellable
        )
        if let cancelButton {
            buttons.append(cancelButton)
        }
        let controlGroup = NativeAlternativePaymentViewModelItem.ControlGroup(id: "control-group", content: buttons)
        return .controlGroup(controlGroup)
    }

    private func update(with state: InteractorState.Redirecting) {
        update(with: state.snapshot, isRedirecting: true)
    }

    private func createRedirectButton(
        state: InteractorState.AwaitingRedirect, isRedirecting: Bool
    ) -> POButtonViewModel {
        // todo(andrii-vysotskyi): decide whether button should be customizable
        let viewModel = POButtonViewModel(
            id: "redirect-button",
            title: state.redirect.hint,
            isEnabled: true,
            isLoading: isRedirecting,
            role: .primary,
            confirmation: nil,
            action: { [weak self] in
                self?.interactor.confirmRedirect()
            }
        )
        return viewModel
    }

    // MARK: - Completed State

    private func update(with state: InteractorState.Completed) {
        let newState = NativeAlternativePaymentViewModelState(
            items: createItems(state: state),
            focusedItemId: nil,
            confirmationDialog: nil
        )
        self.state = newState
    }

    private func createItems(state: InteractorState.Completed) -> [NativeAlternativePaymentViewModelItem] {
        var items: [NativeAlternativePaymentViewModelItem?] = [
            createTitleItem(paymentMethod: state.paymentMethod),
            createSuccessItem(state: state)
        ]
        items.append(contentsOf: createItems(for: state.elements, state: nil))
        if let doneButton = createDoneButton(state: state) {
            items.append(doneButton)
        }
        return items.compactMap { $0 }
    }

    private func createSuccessItem(state: InteractorState.Completed) -> NativeAlternativePaymentViewModelItem {
        // todo(andrii-vysotskyi): support icon customization
        let title = interactor.configuration.success?.title
            ?? String(resource: .NativeAlternativePayment.Success.title)
        let description = interactor.configuration.success?.message
            ?? String(resource: .NativeAlternativePayment.Success.message)
        let item = NativeAlternativePaymentViewModelItem.Success(
            title: title, description: description
        )
        return .success(item)
    }

    private func createDoneButton(state: InteractorState.Completed) -> NativeAlternativePaymentViewModelItem? {
        guard let configuration = interactor.configuration.success?.doneButton else {
            return nil
        }
        let viewModel = POButtonViewModel(
            id: "complete-payment-button",
            title: configuration.title ?? String(resource: .NativeAlternativePayment.Button.done),
            icon: configuration.icon,
            isEnabled: true,
            isLoading: false,
            role: .primary,
            confirmation: nil,
            action: { [weak self] in
                self?.interactor.cancel()
            }
        )
        return .button(viewModel)
    }

    // MARK: - Elements

    private func createItems(
        for elements: [NativeAlternativePaymentResolvedElement], state: InteractorState.Started?
    ) -> [NativeAlternativePaymentViewModelItem] {
        elements.flatMap { element -> [NativeAlternativePaymentViewModelItem] in
            switch element {
            case .form(let form):
                guard let state else {
                    assertionFailure("Unable to create form items without interactor state.")
                    return []
                }
                return createItems(for: form, state: state)
            case .instruction(let instruction):
                return [createItem(for: instruction)]
            case .group(let group):
                return createItems(for: group)
            }
        }
    }

    // MARK: - Input Form

    private func createItems(
        for form: PONativeAlternativePaymentFormV2, state: InteractorState.Started
    ) -> [NativeAlternativePaymentViewModelItem] {
        let items = form.parameters.parameterDefinitions.compactMap { specification in
            guard let parameter = state.parameters[specification.key] else {
                return nil as NativeAlternativePaymentViewModelItem?
            }
            var items = [createItem(parameter: parameter)]
            if let errorMessage = parameter.recentErrorMessage {
                let messageItem = POMessage(id: errorMessage, text: errorMessage, severity: .error)
                items.append(.message(messageItem))
            }
            let group = NativeAlternativePaymentViewModelItem.SizingGroup(
                id: specification.key, content: items
            )
            return .sizingGroup(group)
        }
        return items
    }

    private func createItem(parameter: InteractorState.Parameter) -> NativeAlternativePaymentViewModelItem {
        // todo(andrii-vysotskyi): support new parameter types
        switch parameter.specification {
        case .otp(let specification):
            if let item = createItem(for: parameter, with: specification) {
                return item
            }
        case .phoneNumber(let specification):
            return createItem(for: parameter, with: specification)
        case .singleSelect(let specification):
            return createItem(for: parameter, with: specification)
        case .boolean(let specification):
            return createItem(for: parameter, with: specification)
        default:
            break
        }
        return createInputItem(for: parameter)
    }

    private func createItem(
        for parameter: InteractorState.Parameter,
        with specification: PONativeAlternativePaymentFormV2.Parameter.Otp
    ) -> NativeAlternativePaymentViewModelItem? {
        guard let maxLength = specification.maxLength, maxLength <= Constants.maximumCodeLength else {
            return nil
        }
        let value = Binding<String> {
            if case .string(let value) = parameter.value {
                return value
            }
            return ""
        } set: { [weak self] newValue in
            self?.interactor.updateValue(.string(newValue), for: specification.key)
        }
        let codeInputItem = NativeAlternativePaymentViewModelItem.CodeInput(
            id: specification.key,
            length: maxLength,
            value: value,
            label: specification.label,
            isInvalid: parameter.recentErrorMessage != nil
        )
        return .codeInput(codeInputItem)
    }

    private func createItem(
        for parameter: InteractorState.Parameter,
        with specification: PONativeAlternativePaymentFormV2.Parameter.PhoneNumber
    ) -> NativeAlternativePaymentViewModelItem {
        let territories = specification.dialingCodes.map { dialingCode -> ProcessOutCoreUI.POPhoneNumber.Territory in
            let displayName = Locale.current.localizedString(forRegionCode: dialingCode.regionCode)
            return .init(id: dialingCode.regionCode, displayName: displayName ?? "", code: dialingCode.value)
        }
        let value = Binding<ProcessOutCoreUI.POPhoneNumber> {
            if case .phone(let value) = parameter.value {
                return .init(territoryId: value.regionCode, number: value.number ?? "")
            }
            return .init(territoryId: nil, number: "")
        } set: { [weak self] newValue in
            self?.interactor.updateValue(
                .phone(.init(regionCode: newValue.territoryId, number: newValue.number)),
                for: parameter.specification.key
            )
        }
        let phoneNumberInputItem = NativeAlternativePaymentViewModelItem.PhoneNumberInput(
            id: specification.key,
            territories: territories,
            value: value,
            prompt: specification.label,
            isInvalid: parameter.recentErrorMessage != nil
        )
        return .phoneNumberInput(phoneNumberInputItem)
    }

    private func createItem(
        for parameter: InteractorState.Parameter,
        with specification: PONativeAlternativePaymentFormV2.Parameter.SingleSelect
    ) -> NativeAlternativePaymentViewModelItem {
        let value = Binding<String?> {
            if case .string(let currentValue) = parameter.value {
                return currentValue
            }
            return nil
        } set: { [weak self] newValue in
            self?.interactor.updateValue(.string(newValue ?? ""), for: parameter.specification.key)
        }
        let pickerItem = NativeAlternativePaymentViewModelItem.Picker(
            id: specification.key,
            label: specification.label,
            options: specification.availableValues.map { availableValue in
                .init(id: availableValue.key, title: availableValue.label)
            },
            selectedOptionId: value,
            isInvalid: parameter.recentErrorMessage != nil,
            preferrsInline: specification.availableValues.count <= configuration.inlineSingleSelectValuesLimit
        )
        return .picker(pickerItem)
    }

    private func createInputItem(for parameter: InteractorState.Parameter) -> NativeAlternativePaymentViewModelItem {
        let value = Binding<String> {
            if case .string(let currentValue) = parameter.value {
                return currentValue
            }
            return ""
        } set: { [weak self] newValue in
            self?.interactor.updateValue(.string(newValue), for: parameter.specification.key)
        }
        let inputItem = POTextFieldViewModel(
            id: parameter.specification.key,
            value: value,
            placeholder: parameter.specification.label,
            icon: nil,
            isInvalid: parameter.recentErrorMessage != nil,
            isEnabled: true,
            formatter: parameter.formatter,
            keyboard: keyboard(parameter: parameter.specification),
            contentType: contentType(parameter: parameter.specification),
            submitLabel: .next,
            onSubmit: { [weak self] in
                self?.submitFocusedInput()
            }
        )
        return .input(inputItem)
    }

    private func contentType(
        parameter: PONativeAlternativePaymentFormV2.Parameter
    ) -> UITextContentType? {
        switch parameter {
        case .phoneNumber:
            return .telephoneNumber
        case .email:
            return .emailAddress
        case .otp:
            return .oneTimeCode
        default:
            return nil
        }
    }

    private func keyboard(parameter: PONativeAlternativePaymentFormV2.Parameter) -> UIKeyboardType {
        switch parameter {
        case .text:
            return .default
        case .digits:
            return .numberPad
        case .phoneNumber:
            return .phonePad
        case .email:
            return .emailAddress
        case .card:
            return .numberPad
        case .otp(let specification) where specification.subtype == .digits:
            return .numberPad
        default:
            return .default
        }
    }

    private func createItem(
        for parameter: InteractorState.Parameter,
        with specification: PONativeAlternativePaymentFormV2.Parameter.Boolean
    ) -> NativeAlternativePaymentViewModelItem {
        let isSelected = Binding<Bool> {
            if case .string(let value) = parameter.value {
                return value == true.description
            }
            return false
        } set: { [weak self] newValue in
            self?.interactor.updateValue(.string(newValue.description), for: specification.key)
        }
        let item = NativeAlternativePaymentViewModelItem.ToggleItem(
            id: specification.key, title: specification.label, isSelected: isSelected
        )
        return .toggle(item)
    }

    // MARK: - Customer Instructions

    private func createItem(
        for customerInstruction: NativeAlternativePaymentResolvedElement.Instruction
    ) -> NativeAlternativePaymentViewModelItem {
        switch customerInstruction {
        case .barcode(let instruction):
            let imageItem = NativeAlternativePaymentViewModelItem.Image(
                id: ObjectIdentifier(instruction.image),
                image: instruction.image,
                actionButton: createButton(for: instruction)
            )
            return .image(imageItem)
        case .message(let instruction):
            let item = NativeAlternativePaymentViewModelItem.MessageInstruction(
                id: instruction.value,
                title: instruction.label,
                value: instruction.value
            )
            return .messageInstruction(item)
        case .image(let instruction):
            let item = NativeAlternativePaymentViewModelItem.Image(
                id: ObjectIdentifier(instruction), image: instruction, actionButton: nil
            )
            return .image(item)
        }
    }

    private func createItems(
        for group: NativeAlternativePaymentResolvedElement.Group
    ) -> [NativeAlternativePaymentViewModelItem] {
        let item = NativeAlternativePaymentViewModelItem.Group(
            id: group.label,
            label: group.label,
            items: group.instructions.map { createItem(for: $0) }
        )
        return [.group(item)]
    }

    private func createButton(
        for barcode: NativeAlternativePaymentResolvedElement.Instruction.Barcode
    ) -> POButtonViewModel {
        let configuration = interactor.configuration.barcodeInteraction.saveButton
        let defaultTitle = String(
            resource: .NativeAlternativePayment.Button.saveBarcode,
            replacements: barcode.type.rawValue.uppercased()
        )
        let viewModel = POButtonViewModel(
            id: "barcode-button",
            title: configuration.title ?? defaultTitle,
            icon: configuration.icon,
            action: { [weak self] in
                self?.saveImageToPhotoLibraryOrShowError(barcode.image)
            }
        )
        return viewModel
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
        let parameterIds = startedState.elements.flatMap { element in
            if case let .form(form) = element {
                return form.parameters.parameterDefinitions.map(\.key)
            }
            return []
        }
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

    private func createSubmitButton(state: InteractorState.Started, isLoading: Bool) -> POButtonViewModel {
        let action = POButtonViewModel(
            id: "primary-button",
            title: configuration.submitButton.title ?? String(resource: .NativeAlternativePayment.Button.continue),
            icon: configuration.submitButton.icon,
            isEnabled: state.areParametersValid,
            isLoading: isLoading,
            role: .primary,
            action: { [weak self] in
                self?.interactor.submit()
            }
        )
        return action
    }

    private func createCancelButton(
        configuration: PONativeAlternativePaymentConfiguration.CancelButton?, isEnabled: Bool
    ) -> POButtonViewModel? {
        guard let configuration, !configuration.isHidden else {
            return nil
        }
        let action = POButtonViewModel(
            id: "native-alternative-payment.secondary-button",
            title: configuration.title ?? String(resource: .NativeAlternativePayment.Button.cancel),
            icon: configuration.icon,
            isEnabled: isEnabled,
            role: .cancel,
            confirmation: configuration.confirmation.map { configuration in
                .paymentCancel(with: configuration) { [weak self] in self?.interactor.didRequestCancelConfirmation() }
            },
            action: { [weak self] in
                self?.interactor.cancel()
            }
        )
        return action
    }

    // MARK: - Utils

    private func saveImageToPhotoLibrary(_ image: UIImage) async -> Bool {
        switch await PHPhotoLibrary.requestAuthorization(for: .addOnly) {
        case .notDetermined:
            assertionFailure("Unexpected 'notDetermined' status after requesting explicit authorization.")
            return false
        case .denied, .restricted:
            return false
        case .authorized, .limited:
            break
        @unknown default:
            break // Attempt to save anyway
        }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        } catch {
            return false
        }
        return true
    }

    private func createTitleItem(
        paymentMethod: NativeAlternativePaymentResolvedPaymentMethod
    ) -> NativeAlternativePaymentViewModelItem? {
        let title = interactor.configuration.title ?? paymentMethod.displayName
        guard !title.isEmpty else {
            return nil
        }
        let item = NativeAlternativePaymentViewModelItem.Title(
            id: "Title",
            icon: paymentMethod.logo.map(Image.init),
            text: title
        )
        return .title(item)
    }
}

// swiftlint:enable type_body_length file_length
