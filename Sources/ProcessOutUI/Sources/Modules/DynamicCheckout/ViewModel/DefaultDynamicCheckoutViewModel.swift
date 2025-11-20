//
//  DefaultDynamicCheckoutViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import Foundation
import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

// swiftlint:disable type_body_length file_length

final class DefaultDynamicCheckoutViewModel: ViewModel {

    init(interactor: some DynamicCheckoutInteractor) {
        self.interactor = interactor
        observeChanges(interactor: interactor)
    }

    deinit {
        Task { @MainActor [interactor] in interactor.cancel() }
    }

    // MARK: - DynamicCheckoutViewModel

    @AnimatablePublished
    var state: DynamicCheckoutViewModelState = .idle

    func start() {
        $state.performWithoutAnimation(interactor.start)
    }

    // MARK: - Private Nested Types

    private enum ButtonId {
        static let submit = "Submit"
        static let cancel = "Cancel"
        static let expressCheckoutSettings = "ExpressCheckoutSettings"
    }

    public enum SectionId {
        static let `default` = "Default"
        static let error = "Error"
        static let expressMethods = "ExpressMethods"
        static let regularMethods = "RegularMethods"
    }

    public enum ItemId {
        static let success = "Success"
    }

    // MARK: - Private Properties

    private let interactor: any DynamicCheckoutInteractor

    // MARK: - Interactor Observation

    private func observeChanges(interactor: some Interactor) {
        interactor.didChange = { [weak self] in
            self?.updateWithInteractorState()
        }
        updateWithInteractorState()
    }

    private func updateWithInteractorState() {
        switch interactor.state {
        case .idle, .failure:
            break // Ignored
        case .starting:
            updateWithStartingState()
        case .started(let state):
            updateWithStartedState(state)
        case .selected(let state):
            updateWithSelectedState(state)
        case .paymentProcessing(let state):
            updateWithPaymentProcessingState(state)
        case .restarting(let state):
            updateWithRestartingState(state)
        case .success:
            updateWithSuccessState()
        }
    }

    // MARK: - Starting State

    private func updateWithStartingState() {
        let section = DynamicCheckoutViewModelState.Section(
            id: SectionId.default, header: nil, items: [.progress], isTight: false, areBezelsVisible: false
        )
        state = DynamicCheckoutViewModelState(sections: [section], actions: [])
    }

    // MARK: - Started

    private func updateWithStartedState(_ state: DynamicCheckoutInteractorState.Started) {
        let newActions = [
            createCancelAction(state)
        ]
        let newState = DynamicCheckoutViewModelState(
            sections: createSectionsWithStartedState(state, selectedMethodId: nil, shouldSaveSelectedMethod: nil),
            actions: newActions.compactMap { $0 },
            savedPaymentMethods: self.state.savedPaymentMethods
        )
        self.state = newState
    }

    private func createSectionsWithStartedState(
        _ state: DynamicCheckoutInteractorState.Started, selectedMethodId: String?, shouldSaveSelectedMethod: Bool?
    ) -> [DynamicCheckoutViewModelState.Section] {
        var sections = [
            createErrorSection(state: state),
            createExpressMethodsSection(state: state, processedPaymentMethodId: nil)
        ]
        let regularItems = state.paymentMethods.compactMap { paymentMethod -> DynamicCheckoutViewModelItem? in
            guard !isExpress(paymentMethod: paymentMethod) else {
                return nil
            }
            let isSelected = selectedMethodId == paymentMethod.id
            guard let info = createPaymentInfo(
                for: paymentMethod,
                isSelected: isSelected,
                isLoading: false,
                shouldSaveSelected: shouldSaveSelectedMethod,
                state: state
            ) else {
                return nil
            }
            let payment = DynamicCheckoutViewModelItem.RegularPayment(
                id: paymentMethod.id,
                info: info,
                content: nil,
                submitButton: createSubmitAction(for: paymentMethod.id, selectedMethodId: selectedMethodId)
            )
            return .regularPayment(payment)
        }
        let regularSection = DynamicCheckoutViewModelState.Section(
            id: SectionId.regularMethods, header: nil, items: regularItems, isTight: true, areBezelsVisible: true
        )
        sections.append(regularSection)
        return sections.compactMap { $0 }
    }

    private func createErrorSection(
        state: DynamicCheckoutInteractorState.Started
    ) -> DynamicCheckoutViewModelState.Section? {
        guard let description = state.recentErrorDescription else {
            return nil
        }
        let item = POMessage(id: description, text: description, severity: .error)
        let section = DynamicCheckoutViewModelState.Section(
            id: SectionId.error, header: nil, items: [.message(item)], isTight: false, areBezelsVisible: false
        )
        return section
    }

    private func createExpressMethodsSection(
        state: DynamicCheckoutInteractorState.Started, processedPaymentMethodId: String?
    ) -> DynamicCheckoutViewModelState.Section? {
        let expressItems = state.paymentMethods.compactMap { paymentMethod in
            createExpressPaymentItem(for: paymentMethod, processedPaymentMethodId: processedPaymentMethodId)
        }
        guard !expressItems.isEmpty else {
            return nil
        }
        return .init(
            id: SectionId.expressMethods,
            header: createExpressMethodsSectionHeader(state: state),
            items: expressItems,
            isTight: false,
            areBezelsVisible: false
        )
    }

    private func createExpressMethodsSectionHeader(
        state: DynamicCheckoutInteractorState.Started
    ) -> DynamicCheckoutViewModelState.SectionHeader? {
        let resolvedConfiguration = interactor.configuration.expressCheckout.resolved(
            defaultTitle: String(
                resource: .DynamicCheckout.expressCheckout, configuration: interactor.configuration.localization
            )
        )
        let settingsButton = createExpressMethodsSettingsButton(
            paymentMethods: state.paymentMethods, configuration: resolvedConfiguration.settingsButton
        )
        guard resolvedConfiguration.title != nil || settingsButton != nil else {
            return nil
        }
        return .init(title: resolvedConfiguration.title, button: settingsButton)
    }

    private func createExpressMethodsSettingsButton(
        paymentMethods: [PODynamicCheckoutPaymentMethod],
        configuration: PODynamicCheckoutConfiguration.ExpressCheckoutSettingsButton?
    ) -> POButtonViewModel? {
        let resolvedConfiguration = configuration?.resolved(
            defaultTitle: nil, icon: Image(poResource: .settings).resizable().renderingMode(.template)
        )
        let containsCustomerTokenPaymentMethod = paymentMethods.contains { paymentMethod in
            if case .customerToken(let paymentMethod) = paymentMethod {
                return paymentMethod.configuration.deletingAllowed
            }
            return false
        }
        guard let resolvedConfiguration, containsCustomerTokenPaymentMethod else {
            return nil
        }
        let viewModel = POButtonViewModel(
            id: ButtonId.expressCheckoutSettings,
            title: resolvedConfiguration.title,
            icon: resolvedConfiguration.icon,
            confirmation: nil,
            action: { [weak self] in
                self?.openExpressCheckoutSettings()
            }
        )
        return viewModel
    }

    private func openExpressCheckoutSettings() {
        let viewModel = DynamicCheckoutViewModelState.SavedPaymentMethods(
            id: UUID().uuidString,
            configuration: interactor.savedPaymentMethodsConfiguration(),
            completion: { [weak self]_ in
                self?.state.savedPaymentMethods = nil
            }
        )
        self.state.savedPaymentMethods = viewModel
    }

    private func createPassKitPaymentItem(paymentMethodId: String) -> DynamicCheckoutViewModelItem {
        let item = DynamicCheckoutViewModelItem.PassKitPayment(
            id: paymentMethodId,
            buttonType: interactor.configuration.passKitPaymentButtonType,
            action: { [weak self] in
                self?.interactor.startPayment(methodId: paymentMethodId)
            }
        )
        return .passKitPayment(item)
    }

    private func createExpressPaymentItem(
        for paymentMethod: PODynamicCheckoutPaymentMethod, processedPaymentMethodId: String?
    ) -> DynamicCheckoutViewModelItem? {
        guard isExpress(paymentMethod: paymentMethod) else {
            return nil
        }
        if case .applePay = paymentMethod {
            return createPassKitPaymentItem(paymentMethodId: paymentMethod.id)
        }
        guard let display = paymentMethod.display else {
            return nil
        }
        let item = DynamicCheckoutViewModelItem.ExpressPayment(
            id: paymentMethod.id,
            title: display.description ?? display.name,
            iconImageResource: display.logo,
            brandColor: display.brandColor,
            isLoading: paymentMethod.id == processedPaymentMethodId,
            action: { [weak self] in
                self?.interactor.startPayment(methodId: paymentMethod.id)
            }
        )
        return .expressPayment(item)
    }

    private func createPaymentInfo(
        for paymentMethod: PODynamicCheckoutPaymentMethod,
        isSelected selected: Bool,
        isLoading: Bool,
        shouldSaveSelected: Bool?,
        state: DynamicCheckoutInteractorState.Started
    ) -> DynamicCheckoutViewModelItem.RegularPaymentInfo? {
        guard let isExternal = isExternal(paymentMethod: paymentMethod), let display = paymentMethod.display else {
            return nil
        }
        let isSelected = Binding<Bool> {
            selected
        } set: { [weak self] newValue in
            if newValue {
                self?.didSelectPaymentItem(id: paymentMethod.id, isExternal: isExternal)
            }
        }
        let item = DynamicCheckoutViewModelItem.RegularPaymentInfo(
            iconImageResource: display.logo,
            title: display.description ?? display.name,
            isLoading: isLoading,
            isSelected: isSelected,
            saveTitle: String(
                resource: .DynamicCheckout.savePaymentMessage, configuration: interactor.configuration.localization
            ),
            shouldSave: shouldSavePaymentMethod(
                isSelected: selected, shouldSaveSelected: shouldSaveSelected
            ),
            additionalInformation: additionalPaymentInformation(
                methodId: paymentMethod.id, isExternal: isExternal, isSelected: selected
            )
        )
        return item
    }

    private func shouldSavePaymentMethod(isSelected: Bool, shouldSaveSelected: Bool?) -> Binding<Bool>? {
        guard isSelected, let shouldSaveSelected else {
            return nil
        }
        let binding = Binding(
            get: {
                shouldSaveSelected
            },
            set: { [weak self] newValue in
                self?.interactor.setShouldSaveSelectedPaymentMethod(newValue)
            }
        )
        return binding
    }

    private func didSelectPaymentItem(id: String, isExternal: Bool) {
        if isExternal {
            interactor.select(methodId: id)
        } else {
            interactor.startPayment(methodId: id)
        }
    }

    private func additionalPaymentInformation(methodId: String, isExternal: Bool, isSelected: Bool) -> String? {
        if isExternal, isSelected {
            return String(
                resource: .DynamicCheckout.Warning.redirect, configuration: interactor.configuration.localization
            )
        }
        return nil
    }

    private func createCancelAction(
        _ state: DynamicCheckoutInteractorState.Started
    ) -> POButtonViewModel? {
        guard state.isCancellable else {
            return nil
        }
        guard let configuration = interactor.configuration.cancelButton else {
            return nil
        }
        let cancelAction = createCancelAction(
            title: configuration.title,
            icon: configuration.icon,
            isEnabled: true,
            confirmation: configuration.confirmation
        )
        return cancelAction
    }

    // MARK: - Selected

    private func updateWithSelectedState(_ state: DynamicCheckoutInteractorState.Selected) {
        let newActions = [
            createCancelAction(state.snapshot)
        ]
        let newState = DynamicCheckoutViewModelState(
            sections: createSectionsWithStartedState(
                state.snapshot,
                selectedMethodId: state.paymentMethod.id,
                shouldSaveSelectedMethod: state.shouldSavePaymentMethod
            ),
            actions: newActions.compactMap { $0 },
            savedPaymentMethods: self.state.savedPaymentMethods
        )
        self.state = newState
    }

    private func createSubmitAction(for methodId: String, selectedMethodId: String?) -> POButtonViewModel? {
        guard let selectedMethodId, methodId == selectedMethodId else {
            return nil
        }
        let viewModel = POButtonViewModel(
            id: ButtonId.submit,
            title: interactor.configuration.submitButton.title ?? String(
                resource: .DynamicCheckout.Button.pay, configuration: interactor.configuration.localization
            ),
            icon: interactor.configuration.submitButton.icon,
            role: .primary,
            action: { [weak self] in
                self?.interactor.startPayment(methodId: selectedMethodId)
            }
        )
        return viewModel
    }

    // MARK: - Payment Processing

    private func updateWithPaymentProcessingState(_ state: DynamicCheckoutInteractorState.PaymentProcessing) {
        let newActions = [
            createCancelAction(state)
        ]
        let newState = DynamicCheckoutViewModelState(
            sections: createSectionsWithPaymentProcessingState(state),
            actions: newActions.compactMap { $0 },
            savedPaymentMethods: self.state.savedPaymentMethods
        )
        self.state = newState
    }

    private func createSectionsWithPaymentProcessingState(
        _ state: DynamicCheckoutInteractorState.PaymentProcessing
    ) -> [DynamicCheckoutViewModelState.Section] {
        var sections = [
            createErrorSection(state: state.snapshot),
            createExpressMethodsSection(state: state.snapshot, processedPaymentMethodId: state.paymentMethod.id)
        ]
        let regularItems = state.snapshot.paymentMethods.compactMap { paymentMethod -> DynamicCheckoutViewModelItem? in
            guard !isExpress(paymentMethod: paymentMethod) else {
                return nil
            }
            let (isSelected, isLoading) = status(of: paymentMethod.id, state: state)
            guard let info = createPaymentInfo(
                for: paymentMethod,
                isSelected: isSelected,
                isLoading: isLoading,
                shouldSaveSelected: state.willSavePaymentMethod,
                state: state.snapshot
            ) else {
                return nil
            }
            let payment = DynamicCheckoutViewModelItem.RegularPayment(
                id: paymentMethod.id,
                info: info,
                content: createRegularPaymentContent(for: paymentMethod, state: state),
                submitButton: createSubmitAction(for: paymentMethod.id, in: state)
            )
            return .regularPayment(payment)
        }
        let regularSection = DynamicCheckoutViewModelState.Section(
            id: SectionId.regularMethods,
            header: nil,
            items: regularItems.compactMap { $0 },
            isTight: true,
            areBezelsVisible: true
        )
        sections.append(regularSection)
        return sections.compactMap { $0 }
    }

    private func createRegularPaymentContent(
        for paymentMethod: PODynamicCheckoutPaymentMethod, state: DynamicCheckoutInteractorState.PaymentProcessing
    ) -> DynamicCheckoutViewModelItem.RegularPaymentContent? {
        guard shouldResolveContent(for: paymentMethod.id, state: state) else {
            return nil
        }
        switch paymentMethod {
        case .nativeAlternativePayment:
            guard let interactor = state.nativeAlternativePaymentInteractor else {
                assertionFailure("Interactor must be set.")
                return nil
            }
            let item = DynamicCheckoutViewModelItem.AlternativePayment(id: ObjectIdentifier(interactor)) {
                // todo(andrii-vysotskyi): decide if it is okay to create view model directly here
                let viewModel = DefaultNativeAlternativePaymentViewModel(interactor: interactor)
                return AnyViewModel(erasing: viewModel)
            }
            return .alternativePayment(item)
        case .card:
            guard let interactor = state.cardTokenizationInteractor else {
                assertionFailure("Interactor must be set.")
                return nil
            }
            let item = DynamicCheckoutViewModelItem.Card(id: ObjectIdentifier(interactor)) {
                let viewModel = DefaultCardTokenizationViewModel(interactor: interactor)
                return AnyViewModel(erasing: viewModel)
            }
            return .card(item)
        default:
            return nil
        }
    }

    private func createSubmitAction(
        for methodId: String, in state: DynamicCheckoutInteractorState.PaymentProcessing
    ) -> POButtonViewModel? {
        guard shouldResolveContent(for: methodId, state: state),
              isExternal(paymentMethod: state.paymentMethod) == true else {
            return nil
        }
        let viewModel = POButtonViewModel(
            id: ButtonId.submit,
            title: interactor.configuration.submitButton.title ?? String(
                resource: .DynamicCheckout.Button.pay, configuration: interactor.configuration.localization
            ),
            icon: interactor.configuration.submitButton.icon,
            isLoading: true,
            role: .primary,
            action: { /* Ignored */ }
        )
        return viewModel
    }

    private func createCancelAction(
        _ state: DynamicCheckoutInteractorState.PaymentProcessing
    ) -> POButtonViewModel? {
        guard state.isCancellable || state.snapshot.isCancellable else {
            return nil
        }
        let title: String?, icon: AnyView?, confirmation: POConfirmationDialogConfiguration?
        if state.isAwaitingNativeAlternativePaymentCapture {
            let configuration = state.nativeAlternativePaymentInteractor?.configuration.paymentConfirmation.cancelButton
            title = configuration?.title
            icon = configuration?.icon
            confirmation = configuration?.confirmation
        } else {
            let configuration = interactor.configuration.cancelButton
            title = configuration?.title
            icon = configuration?.icon
            confirmation = configuration?.confirmation
        }
        return createCancelAction(title: title, icon: icon, isEnabled: state.isCancellable, confirmation: confirmation)
    }

    private func shouldResolveContent(
        for methodId: String, state: DynamicCheckoutInteractorState.PaymentProcessing
    ) -> Bool {
        state.paymentMethod.id == methodId && state.isReady
    }

    private func status(
        of methodId: String, state: DynamicCheckoutInteractorState.PaymentProcessing
    ) -> (isSelected: Bool, isLoading: Bool) {
        if methodId == state.paymentMethod.id {
            return (true, !state.isReady)
        }
        return (false, false)
    }

    // MARK: - Restarting State

    private func updateWithRestartingState(_ state: DynamicCheckoutInteractorState.Restarting) {
        let newActions = [
            createCancelAction(state)
        ]
        let newState = DynamicCheckoutViewModelState(
            sections: createSectionsWithRestartingState(state),
            actions: newActions.compactMap { $0 },
            savedPaymentMethods: self.state.savedPaymentMethods
        )
        self.state = newState
    }

    private func createSectionsWithRestartingState(
        _ state: DynamicCheckoutInteractorState.Restarting
    ) -> [DynamicCheckoutViewModelState.Section] {
        var sections = [
            createErrorSection(state: state.snapshot.snapshot),
            createExpressMethodsSection(
                state: state.snapshot.snapshot, processedPaymentMethodId: state.pendingPaymentMethodId
            )
        ]
        // swiftlint:disable:next line_length
        let regularItems = state.snapshot.snapshot.paymentMethods.compactMap { paymentMethod -> DynamicCheckoutViewModelItem? in
            guard !isExpress(paymentMethod: paymentMethod) else {
                return nil
            }
            let isSelected = paymentMethod.id == state.pendingPaymentMethodId
            guard let info = createPaymentInfo(
                for: paymentMethod,
                isSelected: isSelected,
                isLoading: isSelected,
                shouldSaveSelected: nil,
                state: state.snapshot.snapshot
            ) else {
                return nil
            }
            let payment = DynamicCheckoutViewModelItem.RegularPayment(
                id: paymentMethod.id, info: info, content: nil, submitButton: nil
            )
            return .regularPayment(payment)
        }
        let regularSection = DynamicCheckoutViewModelState.Section(
            id: SectionId.regularMethods, header: nil, items: regularItems, isTight: true, areBezelsVisible: true
        )
        sections.append(regularSection)
        return sections.compactMap { $0 }
    }

    private func createCancelAction(
        _ state: DynamicCheckoutInteractorState.Restarting
    ) -> POButtonViewModel? {
        guard state.snapshot.isCancellable || state.snapshot.snapshot.isCancellable else {
            return nil
        }
        guard let configuration = interactor.configuration.cancelButton else {
            return nil
        }
        return createCancelAction(
            title: configuration.title,
            icon: configuration.icon,
            isEnabled: true,
            confirmation: configuration.confirmation
        )
    }

    // MARK: - Success

    private func updateWithSuccessState() {
        guard let configuration = interactor.configuration.paymentSuccess else {
            return
        }
        let title = configuration.title ?? String(
            resource: .DynamicCheckout.successTitle, configuration: interactor.configuration.localization
        )
        let message = configuration.message ?? String(
            resource: .DynamicCheckout.successMessage, configuration: interactor.configuration.localization
        )
        let item = DynamicCheckoutViewModelItem.Success(
            id: ItemId.success, title: title, message: message
        )
        let section = DynamicCheckoutViewModelState.Section(
            id: SectionId.default, header: nil, items: [.success(item)], isTight: false, areBezelsVisible: false
        )
        state = DynamicCheckoutViewModelState(sections: [section], actions: [])
    }

    // MARK: - Utils

    private func createCancelAction(
        title: String?, icon: AnyView?, isEnabled: Bool, confirmation: POConfirmationDialogConfiguration?
    ) -> POButtonViewModel {
        let localizationConfiguration = interactor.configuration.localization
        let viewModel = POButtonViewModel(
            id: ButtonId.cancel,
            title: title ?? String(
                resource: .DynamicCheckout.Button.cancel, configuration: interactor.configuration.localization
            ),
            icon: icon,
            isEnabled: isEnabled,
            role: .cancel,
            confirmation: confirmation.map { configuration in
                .paymentCancel(with: configuration, localization: localizationConfiguration) { [weak self] in
                    self?.interactor.didRequestCancelConfirmation()
                }
            },
            action: { [weak self] in
                self?.interactor.cancel()
            }
        )
        return viewModel
    }

    // MARK: - Utils

    private func isExpress(paymentMethod: PODynamicCheckoutPaymentMethod) -> Bool {
        switch paymentMethod {
        case .applePay:
            return true
        case .alternativePayment(let method):
            return method.flow == .express
        case .nativeAlternativePayment, .card:
            return false
        case .customerToken(let method):
            return method.flow == .express
        case .unknown:
            return false
        @unknown default:
            return false
        }
    }

    private func isExternal(paymentMethod: PODynamicCheckoutPaymentMethod) -> Bool? {
        switch paymentMethod {
        case .alternativePayment:
            return true
        case .nativeAlternativePayment:
            return false
        case .card:
            return false
        case .customerToken(let paymentMethod):
            return paymentMethod.configuration.redirectUrl != nil
        case .applePay, .unknown:
            return nil
        @unknown default:
            return nil
        }
    }
}

// swiftlint:enable type_body_length
