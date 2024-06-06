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

    // MARK: - DynamicCheckoutViewModel

    @Published
    var state: DynamicCheckoutViewModelState = .idle

    func start() {
        interactor.start()
    }

    // MARK: - Private Nested Types

    private enum ButtonId {
        static let submit = "Submit"
        static let cancel = "Cancel"
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
        case .success:
            updateWithSuccessState()
        }
    }

    // MARK: - Starting State

    private func updateWithStartingState() {
        let section = DynamicCheckoutViewModelState.Section(
            id: SectionId.default, items: [.progress], isTight: false, areBezelsVisible: false
        )
        let newState = DynamicCheckoutViewModelState(sections: [section], actions: [], isCompleted: false)
        setState(newState)
    }

    // MARK: - Started

    private func updateWithStartedState(_ state: DynamicCheckoutInteractorState.Started) {
        let newActions = [
            createCancelAction(state)
        ]
        let newState = DynamicCheckoutViewModelState(
            sections: createSectionsWithStartedState(state, selectedMethodId: nil),
            actions: newActions.compactMap { $0 },
            isCompleted: false
        )
        setState(newState)
    }

    private func createSectionsWithStartedState(
        _ state: DynamicCheckoutInteractorState.Started, selectedMethodId: String?
    ) -> [DynamicCheckoutViewModelState.Section] {
        var sections = [
            createErrorSection(state: state),
            createExpressMethodsSection(state: state)
        ]
        let regularItems = state.regularPaymentMethodIds.compactMap { methodId -> DynamicCheckoutViewModelItem? in
            let isSelected = selectedMethodId == methodId
            // swiftlint:disable:next line_length
            guard let info = createPaymentInfo(id: methodId, isSelected: isSelected, isLoading: false, state: state) else {
                return nil
            }
            let submitButton = createSubmitAction(selectedMethodId: selectedMethodId)
            let payment = DynamicCheckoutViewModelItem.RegularPayment(
                id: methodId, info: info, content: nil, submitButton: submitButton
            )
            return .regularPayment(payment)
        }
        let regularSection = DynamicCheckoutViewModelState.Section(
            id: SectionId.regularMethods, items: regularItems, isTight: true, areBezelsVisible: true
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
            id: SectionId.error, items: [.message(item)], isTight: false, areBezelsVisible: false
        )
        return section
    }

    private func createExpressMethodsSection(
        state: DynamicCheckoutInteractorState.Started
    ) -> DynamicCheckoutViewModelState.Section? {
        let expressItems = state.expressPaymentMethodIds.compactMap { methodId in
            createExpressPaymentItem(id: methodId, state: state)
        }
        guard !expressItems.isEmpty else {
            return nil
        }
        return .init(id: SectionId.expressMethods, items: expressItems, isTight: false, areBezelsVisible: false)
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
        id: String, state: DynamicCheckoutInteractorState.Started
    ) -> DynamicCheckoutViewModelItem? {
        guard let method = state.paymentMethods[id] else {
            assertionFailure("Unexpected payment method ID.")
            return nil
        }
        let display: PODynamicCheckoutPaymentMethod.Display
        switch method {
        case .applePay:
            return createPassKitPaymentItem(paymentMethodId: id)
        case .alternativePayment(let method):
            display = method.display
        case .nativeAlternativePayment, .card, .unknown:
            return nil
        }
        let item = DynamicCheckoutViewModelItem.ExpressPayment(
            id: id,
            title: display.name,
            iconImageResource: display.logo,
            brandColor: display.brandColor,
            action: { [weak self] in
                self?.interactor.startPayment(methodId: id)
            }
        )
        return .expressPayment(item)
    }

    private func createPaymentInfo(
        id: String, isSelected selected: Bool, isLoading: Bool, state: DynamicCheckoutInteractorState.Started
    ) -> DynamicCheckoutViewModelItem.RegularPaymentInfo? {
        guard let method = state.paymentMethods[id] else {
            assertionFailure("Unable to resolve payment method by ID")
            return nil
        }
        let display: PODynamicCheckoutPaymentMethod.Display, isExternal: Bool
        switch method {
        case .alternativePayment(let method):
            display = method.display
            isExternal = true
        case .nativeAlternativePayment(let method):
            display = method.display
            isExternal = false
        case .card(let method):
            display = method.display
            isExternal = false
        case .applePay, .unknown:
            return nil
        }
        let isSelected = Binding<Bool> {
            selected
        } set: { [weak self] newValue in
            if newValue {
                self?.didSelectPaymentItem(id: id, isExternal: isExternal)
            }
        }
        let isAvailable = !state.unavailablePaymentMethodIds.contains(id)
        let item = DynamicCheckoutViewModelItem.RegularPaymentInfo(
            iconImageResource: display.logo,
            brandColor: display.brandColor,
            title: display.name,
            isLoading: isLoading,
            isSelectable: isAvailable,
            isSelected: isSelected,
            additionalInformation: additionalPaymentInformation(
                methodId: id, isAvailable: isAvailable, isExternal: isExternal
            )
        )
        return item
    }

    private func didSelectPaymentItem(id: String, isExternal: Bool) {
        if isExternal {
            interactor.select(methodId: id)
        } else {
            interactor.startPayment(methodId: id)
        }
    }

    private func additionalPaymentInformation(methodId: String, isAvailable: Bool, isExternal: Bool) -> String? {
        if !isAvailable {
            return String(resource: .DynamicCheckout.Warning.paymentUnavailable)
        } else if isExternal {
            return String(resource: .DynamicCheckout.Warning.redirect)
        }
        return nil
    }

    private func createCancelAction(
        _ state: DynamicCheckoutInteractorState.Started
    ) -> POActionsContainerActionViewModel? {
        guard state.isCancellable else {
            return nil
        }
        let cancelAction = createCancelAction(
            title: interactor.configuration.cancelButton?.title,
            isEnabled: true,
            confirmation: interactor.configuration.cancelButton?.confirmation
        )
        return cancelAction
    }

    // MARK: - Selected

    private func updateWithSelectedState(_ state: DynamicCheckoutInteractorState.Selected) {
        let newActions = [
            createCancelAction(state.snapshot)
        ]
        let newState = DynamicCheckoutViewModelState(
            sections: createSectionsWithStartedState(state.snapshot, selectedMethodId: state.paymentMethodId),
            actions: newActions.compactMap { $0 },
            isCompleted: false
        )
        setState(newState)
    }

    private func createSubmitAction(selectedMethodId: String?) -> POActionsContainerActionViewModel? {
        guard let selectedMethodId else {
            return nil
        }
        let viewModel = POActionsContainerActionViewModel(
            id: ButtonId.submit + selectedMethodId,
            title: interactor.configuration.primaryButtonTitle ?? String(resource: .DynamicCheckout.Button.continue),
            isEnabled: true,
            isLoading: false,
            isPrimary: true,
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
            isCompleted: false
        )
        setState(newState)
    }

    private func createSectionsWithPaymentProcessingState(
        _ state: DynamicCheckoutInteractorState.PaymentProcessing
    ) -> [DynamicCheckoutViewModelState.Section] {
        var sections = [
            createErrorSection(state: state.snapshot),
            createExpressMethodsSection(state: state.snapshot)
        ]
        // swiftlint:disable:next line_length
        let regularItems = state.snapshot.regularPaymentMethodIds.compactMap { methodId -> DynamicCheckoutViewModelItem? in
            let isSelected = state.paymentMethodId == methodId
            // swiftlint:disable:next line_length
            guard let info = createPaymentInfo(id: methodId, isSelected: isSelected, isLoading: isSelected && !state.isReady, state: state.snapshot) else {
                return nil
            }
            let payment = DynamicCheckoutViewModelItem.RegularPayment(
                id: methodId,
                info: info,
                content: createRegularPaymentContent(state: state, methodId: methodId),
                submitButton: createSubmitAction(methodId: methodId, state: state)
            )
            return .regularPayment(payment)
        }
        let regularSection = DynamicCheckoutViewModelState.Section(
            id: SectionId.regularMethods, items: regularItems.compactMap { $0 }, isTight: true, areBezelsVisible: true
        )
        sections.append(regularSection)
        return sections.compactMap { $0 }
    }

    private func createRegularPaymentContent(
        state: DynamicCheckoutInteractorState.PaymentProcessing, methodId: String
    ) -> DynamicCheckoutViewModelItem.RegularPaymentContent? {
        guard state.isReady, state.paymentMethodId == methodId else {
            return nil
        }
        guard let method = state.snapshot.paymentMethods[methodId] else {
            assertionFailure("Unable to resolve payment method by ID")
            return nil
        }
        switch method {
        case .nativeAlternativePayment:
            guard let interactor = state.nativeAlternativePaymentInteractor else {
                assertionFailure("Interactor must be set.")
                return nil
            }
            let item = DynamicCheckoutViewModelItem.AlternativePayment {
                // todo(andrii-vysotskyi): decide if it is okay to create view model directly here
                let viewModel = DefaultNativeAlternativePaymentViewModel(interactor: interactor)
                return AnyNativeAlternativePaymentViewModel(erasing: viewModel)
            }
            return .alternativePayment(item)
        case .card:
            guard let interactor = state.cardTokenizationInteractor else {
                assertionFailure("Interactor must be set.")
                return nil
            }
            let item = DynamicCheckoutViewModelItem.Card {
                let viewModel = DefaultCardTokenizationViewModel(interactor: interactor)
                return AnyViewModel(erasing: viewModel)
            }
            return .card(item)
        default:
            return nil
        }
    }

    private func createSubmitAction(
        methodId: String, state: DynamicCheckoutInteractorState.PaymentProcessing
    ) -> POActionsContainerActionViewModel? {
        guard methodId == state.paymentMethodId, state.isReady else {
            return nil
        }
        let isEnabled, isLoading: Bool
        switch state.submission {
        case .temporarilyUnavailable:
            isEnabled = false
            isLoading = false
        case .possible:
            isEnabled = true
            isLoading = false
        case .submitting:
            isEnabled = true
            isLoading = true
        }
        let viewModel = POActionsContainerActionViewModel(
            id: ButtonId.submit + state.paymentMethodId,
            title: interactor.configuration.primaryButtonTitle ?? String(resource: .DynamicCheckout.Button.continue),
            isEnabled: isEnabled,
            isLoading: isLoading,
            isPrimary: true,
            action: { [weak self] in
                self?.interactor.submit()
            }
        )
        return viewModel
    }

    private func createCancelAction(
        _ state: DynamicCheckoutInteractorState.PaymentProcessing
    ) -> POActionsContainerActionViewModel? {
        guard state.isCancellable || state.snapshot.isCancellable else {
            return nil
        }
        let title: String?
        let confirmation: POConfirmationDialogConfiguration?
        if state.isAwaitingNativeAlternativePaymentCapture {
            let configuration = interactor.configuration.alternativePayment.captureConfirmation.cancelButton
            title = configuration?.title
            confirmation = configuration?.confirmation
        } else {
            let configuration = interactor.configuration.cancelButton
            title = configuration?.title
            confirmation = configuration?.confirmation
        }
        return createCancelAction(title: title, isEnabled: state.isCancellable, confirmation: confirmation)
    }

    // MARK: - Success

    private func updateWithSuccessState() {
        guard let configuration = interactor.configuration.captureSuccess else {
            return
        }
        let message = configuration.message ?? String(resource: .DynamicCheckout.successMessage)
        let item = DynamicCheckoutViewModelItem.Success(
            id: ItemId.success, message: message, image: UIImage(resource: .success)
        )
        let section = DynamicCheckoutViewModelState.Section(
            id: SectionId.default, items: [.success(item)], isTight: false, areBezelsVisible: false
        )
        let newState = DynamicCheckoutViewModelState(sections: [section], actions: [], isCompleted: true)
        setState(newState)
    }

    // MARK: - Utils

    private func createCancelAction(
        title: String?, isEnabled: Bool, confirmation: POConfirmationDialogConfiguration?
    ) -> POActionsContainerActionViewModel? {
        let viewModel = POActionsContainerActionViewModel(
            id: ButtonId.cancel,
            title: title ?? String(resource: .DynamicCheckout.Button.cancel),
            isEnabled: isEnabled,
            isLoading: false,
            isPrimary: false,
            action: { [weak self] in
                self?.cancelCheckout(configuration: confirmation)
            }
        )
        return viewModel
    }

    private func setState(_ newState: DynamicCheckoutViewModelState) {
        let isAnimated = newState.animationIdentity != state.animationIdentity
        withAnimation(isAnimated ? .default : nil) {
            state = newState
        }
    }

    private func cancelCheckout(configuration: POConfirmationDialogConfiguration?) {
        if let configuration = configuration {
            interactor.didRequestCancelConfirmation()
            let confirmationDialog = POConfirmationDialog(
                title: configuration.title ?? String(resource: .DynamicCheckout.CancelConfirmation.title),
                message: configuration.message,
                primaryButton: .init(
                    // swiftlint:disable:next line_length
                    title: configuration.confirmActionTitle ?? String(resource: .DynamicCheckout.CancelConfirmation.confirm),
                    role: .destructive,
                    action: { [weak self] in
                        self?.interactor.cancel()
                    }
                ),
                secondaryButton: .init(
                    // swiftlint:disable:next line_length
                    title: configuration.cancelActionTitle ?? String(resource: .DynamicCheckout.CancelConfirmation.cancel),
                    role: .cancel
                )
            )
            state.confirmationDialog = confirmationDialog
        } else {
            interactor.cancel()
        }
    }
}

// swiftlint:enable type_body_length
