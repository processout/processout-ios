//
//  DefaultCardTokenizationViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 20.07.2023.
//

import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

// swiftlint:disable type_body_length file_length

final class DefaultCardTokenizationViewModel: ViewModel {

    init(interactor: any CardTokenizationInteractor) {
        self.interactor = interactor
        state = .idle
        observeChanges(interactor: interactor)
    }

    deinit {
        Task { @MainActor [interactor] in interactor.cancel() }
    }

    // MARK: - CardTokenizationViewModel

    @AnimatablePublished
    var state: CardTokenizationViewModelState

    func start() {
        $state.performWithoutAnimation(interactor.start)
    }

    // MARK: - Private Nested Types

    private typealias InteractorState = CardTokenizationInteractorState

    private enum SectionId {
        static let title = "title"
        static let cardInformation = "card-info"
        static let preferredScheme = "preferred-scheme"
        static let billingAddress = "billing-address"
        static let futurePayments = "future-payments"
    }

    private enum ItemId {
        static let error = "error"
        static let trackData = "track-data"
        static let scheme = "card-scheme"
        static let cardSave = "card-save"
    }

    // MARK: - Private Properties

    private let interactor: any CardTokenizationInteractor

    private var configuration: POCardTokenizationConfiguration {
        interactor.configuration
    }

    // MARK: - Private Methods

    private func observeChanges(interactor: any Interactor) {
        interactor.didChange = { [weak self] in
            self?.configureWithInteractorState()
        }
        configureWithInteractorState()
    }

    private func configureWithInteractorState() {
        switch interactor.state {
        case .idle:
            state = .idle
        case .started(let currentState):
            let newState = convertToState(startedState: currentState, isSubmitting: false)
            self.state = newState
        case .tokenizing(let currentState):
            let newState = convertToState(startedState: currentState.snapshot, isSubmitting: true)
            self.state = newState
        default:
            break
        }
    }

    // MARK: - Started State

    private func convertToState(
        startedState: InteractorState.Started, isSubmitting: Bool
    ) -> CardTokenizationViewModelState {
        var cardInformationItems = cardInformationInputItems(startedState: startedState)
        if let error = startedState.recentErrorMessage {
            let errorItem = State.ErrorItem(id: ItemId.error, description: error)
            cardInformationItems.append(.error(errorItem))
        }
        let sections = [
            State.Section(
                id: SectionId.cardInformation,
                title: nil,
                items: cardInformationItems
            ),
            preferredSchemeSection(startedState: startedState),
            billingAddressSection(startedState: startedState),
            futurePaymentsSection(startedState: startedState)
        ]
        let startedState = State(
            title: title(),
            sections: sections.compactMap { $0 },
            actions: createActions(startedState: startedState, isSubmitting: isSubmitting),
            focusedInputId: focusedInputId(startedState: startedState, isSubmitting: isSubmitting)
        )
        return startedState
    }

    // MARK: - Title

    private func title() -> String? {
        let title = configuration.title ?? String(resource: .CardTokenization.title)
        return title.isEmpty ? nil : title
    }

    // MARK: - Card Details

    private func cardInformationInputItems(
        startedState: InteractorState.Started
    ) -> [CardTokenizationViewModelState.Item] {
        let trackItems = [
            createItem(
                parameter: startedState.expiration,
                // swiftlint:disable:next line_length
                placeholder: configuration.expirationDate.prompt ?? String(resource: .CardTokenization.CardDetails.expiration),
                icon: configuration.expirationDate.icon,
                keyboard: .asciiCapableNumberPad
            ),
            createItem(
                parameter: startedState.cvc,
                placeholder: configuration.cvc?.prompt ?? String(resource: .CardTokenization.CardDetails.cvc),
                icon: configuration.cvc?.icon ?? AnyView(Image(poResource: .Card.back).renderingMode(.template)),
                keyboard: .asciiCapableNumberPad
            )
        ]
        let items = [
            createCardScanButtonItem(),
            createItem(
                parameter: startedState.number,
                placeholder: configuration.cardNumber.prompt ?? String(resource: .CardTokenization.CardDetails.number),
                icon: cardNumberIcon(startedState: startedState),
                keyboard: .asciiCapableNumberPad,
                contentType: .creditCardNumber
            ),
            .group(
                State.GroupItem(id: ItemId.trackData, items: trackItems.compactMap { $0 })
            ),
            createItem(
                parameter: startedState.cardholderName,
                // swiftlint:disable:next line_length
                placeholder: configuration.cardholderName?.prompt ?? String(resource: .CardTokenization.CardDetails.cardholder),
                icon: configuration.cardholderName?.icon,
                keyboard: .asciiCapable,
                contentType: .name,
                submitLabel: .done
            )
        ]
        return items.compactMap { $0 }
    }

    private func cardNumberIcon(startedState: InteractorState.Started) -> AnyView? {
        // Scheme icon takes precedence over inject icon.
        let scheme = startedState.issuerInformation?.coScheme != nil
            ? startedState.preferredScheme
            : startedState.issuerInformation?.$scheme.typed
        if let image = scheme.flatMap(CardSchemeImageProvider.shared.image) {
            return AnyView(image)
        }
        return configuration.cardNumber.icon
    }

    private func createCardScanButtonItem() -> State.Item? {
        guard let cardScanner = configuration.cardScanner else {
            return nil
        }
        let openScanner: @MainActor () -> Void = { [weak self] in
            self?.state.cardScanner = .init(id: "card-scanner", configuration: cardScanner.configuration) { result in
                if case .success(let card) = result {
                    self?.interactor.update(with: card)
                }
                self?.state.cardScanner = nil
            }
        }
        let defaultIcon = Image(poResource: .camera)
            .renderingMode(.template)
            .resizable()
        let viewModel = POButtonViewModel(
            id: "scan-card-button",
            title: cardScanner.scanButton.title ?? String(resource: .CardTokenization.Button.scanCard),
            icon: cardScanner.scanButton.icon ?? AnyView(defaultIcon),
            action: openScanner
        )
        return .button(viewModel)
    }

    // MARK: - Preferred Scheme

    private func preferredSchemeSection(
        startedState: InteractorState.Started
    ) -> CardTokenizationViewModelState.Section? {
        guard configuration.isSchemeSelectionAllowed,
              let issuerInformation = startedState.issuerInformation,
              let coScheme = issuerInformation.coScheme else {
            return nil
        }
        let pickerItem = State.PickerItem(
            id: ItemId.scheme,
            options: [
                .init(id: issuerInformation.scheme, title: issuerInformation.scheme.capitalized),
                .init(id: coScheme, title: coScheme.capitalized)
            ],
            selectedOptionId: .init(
                get: { startedState.preferredScheme?.rawValue },
                set: { [weak self] newValue in
                    let newScheme = newValue.map(POCardScheme.init)
                    self?.interactor.setPreferredScheme(newScheme ?? issuerInformation.$scheme.typed)
                }
            ),
            preferrsInline: true
        )
        let section = State.Section(
            id: SectionId.preferredScheme,
            title: String(resource: .CardTokenization.PreferredScheme.title),
            items: [.picker(pickerItem)]
        )
        return section
    }

    // MARK: - Billing Address

    private func billingAddressSection(
        startedState: InteractorState.Started
    ) -> CardTokenizationViewModelState.Section? {
        var items: [CardTokenizationViewModelState.Item] = []
        if let item = createItem(parameter: startedState.address.country, placeholder: "") {
            items.append(item)
        }
        items += startedState.address.specification.units.flatMap { unit in
            createAddressItems(unit: unit, startedState: startedState)
        }
        guard !items.isEmpty else {
            return nil
        }
        let section = CardTokenizationViewModelState.Section(
            id: SectionId.billingAddress,
            title: String(resource: .CardTokenization.BillingAddress.title),
            items: items
        )
        return section
    }

    private func createAddressItems(
        unit: AddressSpecification.Unit, startedState: InteractorState.Started
    ) -> [CardTokenizationViewModelState.Item] {
        var items: [CardTokenizationViewModelState.Item?] = []
        switch unit {
        case .street:
            let streetItems = [
                createItem(
                    parameter: startedState.address.street1,
                    placeholder: String(resource: .CardTokenization.BillingAddress.street, replacements: 1)
                ),
                createItem(
                    parameter: startedState.address.street2,
                    placeholder: String(resource: .CardTokenization.BillingAddress.street, replacements: 2)
                )
            ]
            items.append(contentsOf: streetItems)
        case .city:
            let placeholder = String(resource: startedState.address.specification.cityUnit.stringResource)
            items.append(createItem(parameter: startedState.address.city, placeholder: placeholder))
        case .state:
            let placeholder = String(resource: startedState.address.specification.stateUnit.stringResource)
            items.append(createItem(parameter: startedState.address.state, placeholder: placeholder))
        case .postcode:
            let placeholder = String(resource: startedState.address.specification.postcodeUnit.stringResource)
            items.append(createItem(parameter: startedState.address.postalCode, placeholder: placeholder))
        }
        return items.compactMap { $0 }
    }

    // MARK: - Future Payments

    private func futurePaymentsSection(
        startedState: InteractorState.Started
    ) -> CardTokenizationViewModelState.Section? {
        guard interactor.configuration.isSavingAllowed else {
            return nil
        }
        let toggleItem = CardTokenizationViewModelState.ToggleItem(
            id: ItemId.cardSave,
            title: String(resource: .CardTokenization.saveCardMessage),
            isSelected: .init(
                get: { startedState.shouldSaveCard },
                set: { [weak self] newValue in
                    self?.interactor.setShouldSaveCard(newValue)
                }
            )
        )
        let section = CardTokenizationViewModelState.Section(
            id: SectionId.futurePayments, title: nil, items: [.toggle(toggleItem)]
        )
        return section
    }

    // MARK: - Input & Picker Items

    private func createItem(
        parameter: InteractorState.Parameter,
        placeholder: String,
        icon: AnyView? = nil,
        keyboard: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        submitLabel: POBackport<Any>.SubmitLabel = .default
    ) -> CardTokenizationViewModelState.Item? {
        guard parameter.shouldCollect else {
            return nil
        }
        if parameter.availableValues.isEmpty {
            return createInputItem(
                parameter: parameter,
                placeholder: placeholder,
                icon: icon,
                keyboard: keyboard,
                contentType: contentType,
                submitLabel: submitLabel
            )
        }
        return createPickerItem(parameter: parameter)
    }

    private func createInputItem(
        parameter: InteractorState.Parameter,
        placeholder: String,
        icon: AnyView? = nil,
        keyboard: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        submitLabel: POBackport<Any>.SubmitLabel
    ) -> CardTokenizationViewModelState.Item {
        let value = Binding<String>(
            get: { parameter.value },
            set: { [weak self] in self?.interactor.update(parameterId: parameter.id, value: $0) }
        )
        let inputItem = State.InputItem(
            id: parameter.id,
            value: value,
            placeholder: placeholder,
            icon: icon,
            isInvalid: !parameter.isValid,
            isEnabled: true,
            formatter: parameter.formatter,
            keyboard: keyboard,
            contentType: contentType,
            submitLabel: submitLabel,
            onSubmit: { [weak self] in
                self?.submitFocusedInput()
            }
        )
        return .input(inputItem)
    }

    private func createPickerItem(parameter: InteractorState.Parameter) -> CardTokenizationViewModelState.Item {
        let options = parameter.availableValues.map { value in
            CardTokenizationViewModelState.PickerItemOption(id: value.value, title: value.displayName)
        }
        let selectedOptionId = Binding<String?>(
            get: { parameter.value },
            set: { [weak self] newValue in
                self?.interactor.update(parameterId: parameter.id, value: newValue ?? "")
            }
        )
        let item = CardTokenizationViewModelState.PickerItem(
            id: parameter.id, options: options, selectedOptionId: selectedOptionId, preferrsInline: false
        )
        return .picker(item)
    }

    // MARK: - Actions

    private func createActions(
        startedState: InteractorState.Started, isSubmitting: Bool
    ) -> [POButtonViewModel] {
        let actions = [
            submitAction(startedState: startedState, isSubmitting: isSubmitting),
            cancelAction(isEnabled: !isSubmitting)
        ]
        return actions.compactMap { $0 }
    }

    private func submitAction(
        startedState: InteractorState.Started, isSubmitting: Bool
    ) -> POButtonViewModel? {
        let buttonConfiguration = configuration.submitButton
        let action = POButtonViewModel(
            id: "primary-button",
            title: buttonConfiguration.title ?? String(resource: .CardTokenization.Button.submit),
            icon: buttonConfiguration.icon,
            isEnabled: startedState.areParametersValid,
            isLoading: isSubmitting,
            role: .primary,
            action: { [weak self] in
                self?.interactor.tokenize()
            }
        )
        return action
    }

    private func cancelAction(isEnabled: Bool) -> POButtonViewModel? {
        guard let buttonConfiguration = configuration.cancelButton else {
            return nil
        }
        let action = POButtonViewModel(
            id: "cancel-button",
            title: buttonConfiguration.title ?? String(resource: .CardTokenization.Button.cancel),
            icon: buttonConfiguration.icon,
            isEnabled: isEnabled,
            role: .cancel,
            confirmation: buttonConfiguration.confirmation.map { .cancel(with: $0, onAppear: nil) },
            action: { [weak self] in
                self?.interactor.cancel()
            }
        )
        return action
    }

    // MARK: - Parameters Submission

    private func submitFocusedInput() {
        guard let focusedInputId = state.focusedInputId else {
            assertionFailure("Unable to identify focused input.")
            return
        }
        guard case .started(let startedState) = interactor.state else {
            return
        }
        let parameterIds = parameters(startedState: startedState).map(\.id)
        guard let focusedInputIndex = parameterIds.map(AnyHashable.init).firstIndex(of: focusedInputId) else {
            return
        }
        if parameterIds.indices.contains(focusedInputIndex + 1) {
            state.focusedInputId = parameterIds[focusedInputIndex + 1]
        } else {
            interactor.tokenize()
        }
    }

    // MARK: - Focus

    /// Returns input identifier that should be focused.
    private func focusedInputId(startedState: InteractorState.Started, isSubmitting: Bool) -> AnyHashable? {
        if isSubmitting {
            return nil
        }
        if let id = state.focusedInputId {
            return id
        }
        let paramters = parameters(startedState: startedState)
        if let index = paramters.map(\.isValid).firstIndex(of: false) {
            // Attempt to focus first invalid parameter if available.
            return paramters[index].id
        }
        return paramters.first?.id
    }

    // MARK: - Utils

    private func parameters(startedState: InteractorState.Started) -> [InteractorState.Parameter] {
        let parameters = [
            startedState.number,
            startedState.expiration,
            startedState.cvc,
            startedState.cardholderName,
            startedState.address.street1,
            startedState.address.street2,
            startedState.address.city,
            startedState.address.state,
            startedState.address.postalCode
        ]
        return parameters.filter(\.shouldCollect)
    }
}

// swiftlint:enable type_body_length file_length
