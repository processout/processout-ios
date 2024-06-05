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
        let section = DynamicCheckoutViewModelSection(
            id: SectionId.default,
            items: [.progress],
            areSeparatorsVisible: false,
            areBezelsVisible: false
        )
        // Confirmation dialog is dismissed when interactor changes
        let newState = DynamicCheckoutViewModelState(
            sections: [section], actions: [], isCompleted: false, confirmationDialog: nil
        )
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
    ) -> [DynamicCheckoutViewModelSection] {
        var sections = [
            createErrorSection(state: state),
            createExpressMethodsSection(state: state)
        ]
        let regularItems = state.regularPaymentMethodIds.compactMap { methodId in
            let isSelected = selectedMethodId == methodId
            return createItem(
                paymentMethodId: methodId, state: state, isExpress: false, isSelected: isSelected, isLoading: false
            )
        }
        let regularSection = DynamicCheckoutViewModelSection(
            id: SectionId.regularMethods,
            items: regularItems,
            areSeparatorsVisible: true,
            areBezelsVisible: true
        )
        sections.append(regularSection)
        return sections.compactMap { $0 }
    }

    private func createErrorSection(state: DynamicCheckoutInteractorState.Started) -> DynamicCheckoutViewModelSection? {
        guard let description = state.recentErrorDescription else {
            return nil
        }
        let item = POMessage(id: description, text: description, severity: .error)
        let section = DynamicCheckoutViewModelSection(
            id: SectionId.error,
            items: [.message(item)],
            areSeparatorsVisible: false,
            areBezelsVisible: false
        )
        return section
    }

    private func createExpressMethodsSection(
        state: DynamicCheckoutInteractorState.Started
    ) -> DynamicCheckoutViewModelSection? {
        let expressItems = state.expressPaymentMethodIds.compactMap { methodId in
            createItem(paymentMethodId: methodId, state: state, isExpress: true, isSelected: false, isLoading: false)
        }
        guard !expressItems.isEmpty else {
            return nil
        }
        let section = DynamicCheckoutViewModelSection(
            id: SectionId.expressMethods,
            items: expressItems,
            areSeparatorsVisible: false,
            areBezelsVisible: false
        )
        return section
    }

    private func createItem(
        paymentMethodId methodId: String,
        state: DynamicCheckoutInteractorState.Started,
        isExpress: Bool,
        isSelected: Bool,
        isLoading: Bool
    ) -> DynamicCheckoutViewModelItem? {
        guard let method = state.paymentMethods[methodId] else {
            assertionFailure("Unable to resolve payment method by ID")
            return nil
        }
        let display: PODynamicCheckoutPaymentMethod.Display
        let isExternal: Bool
        switch method {
        case .applePay:
            return createPassKitPaymentItem(paymentMethodId: methodId)
        case .alternativePayment(let method):
            display = method.display
            isExternal = true
        case .nativeAlternativePayment(let method):
            assert(!isExpress, "Native APMs is not expected to be an express")
            display = method.display
            isExternal = false
        case .card(let method):
            assert(!isExpress, "Card is not expected to be an express")
            display = method.display
            isExternal = false
        case .unknown:
            assertionFailure("Unexpected unknown payment method")
            return nil
        }
        if isExpress {
            return createExpressPaymentItem(id: methodId, display: display)
        }
        return createRegularPaymentItem(
            id: methodId,
            display: display,
            isExternal: isExternal,
            isSelectable: !state.unavailablePaymentMethodIds.contains(methodId),
            isSelected: isSelected,
            isLoading: isLoading
        )
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
        id: String, display: PODynamicCheckoutPaymentMethod.Display
    ) -> DynamicCheckoutViewModelItem {
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

    // swiftlint:disable:next function_parameter_count
    private func createRegularPaymentItem(
        id: String,
        display: PODynamicCheckoutPaymentMethod.Display,
        isExternal: Bool,
        isSelectable: Bool,
        isSelected selected: Bool,
        isLoading: Bool
    ) -> DynamicCheckoutViewModelItem {
        let isSelected = Binding<Bool> {
            selected
        } set: { [weak self] newValue in
            guard let self, newValue else {
                return
            }
            if isExternal {
                self.interactor.select(methodId: id)
            } else {
                self.interactor.startPayment(methodId: id)
            }
        }
        var additionalInformation: String?
        if !isSelectable {
            additionalInformation = String(resource: .DynamicCheckout.Warning.paymentUnavailable)
        } else if isExternal {
            additionalInformation = String(resource: .DynamicCheckout.Warning.redirect)
        }
        let item = DynamicCheckoutViewModelItem.PaymentInfo(
            id: id,
            iconImageResource: display.logo,
            brandColor: display.brandColor,
            title: display.name,
            isLoading: isLoading,
            isSelectable: isSelectable,
            isSelected: isSelected,
            additionalInformation: additionalInformation
        )
        return .payment(item)
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
            createSubmitAction(state),
            createCancelAction(state.snapshot)
        ]
        let newState = DynamicCheckoutViewModelState(
            sections: createSectionsWithStartedState(state.snapshot, selectedMethodId: state.paymentMethodId),
            actions: newActions.compactMap { $0 },
            isCompleted: false
        )
        setState(newState)
    }

    private func createSubmitAction(
        _ state: DynamicCheckoutInteractorState.Selected
    ) -> POActionsContainerActionViewModel? {
        let viewModel = POActionsContainerActionViewModel(
            id: ButtonId.submit,
            title: interactor.configuration.primaryButtonTitle ?? String(resource: .DynamicCheckout.Button.continue),
            isEnabled: true,
            isLoading: false,
            isPrimary: true,
            action: { [weak self] in
                self?.interactor.startPayment(methodId: state.paymentMethodId)
            }
        )
        return viewModel
    }

    // MARK: - Payment Processing

    private func updateWithPaymentProcessingState(_ state: DynamicCheckoutInteractorState.PaymentProcessing) {
        let newActions = [
            createSubmitAction(state),
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
    ) -> [DynamicCheckoutViewModelSection] {
        var sections = [
            createErrorSection(state: state.snapshot),
            createExpressMethodsSection(state: state.snapshot)
        ]
        let regularItems = state.snapshot.regularPaymentMethodIds.flatMap { methodId in
            let isSelected = state.paymentMethodId == methodId
            let item = createItem(
                paymentMethodId: methodId,
                state: state.snapshot,
                isExpress: false,
                isSelected: isSelected,
                isLoading: isSelected && !state.isReady
            )
            guard isSelected, state.isReady else {
                return [item]
            }
            let itemContent = createProcessedItemContent(state: state, methodId: state.paymentMethodId)
            return [item, itemContent]
        }
        let regularSection = DynamicCheckoutViewModelSection(
            id: SectionId.regularMethods,
            items: regularItems.compactMap { $0 },
            areSeparatorsVisible: true,
            areBezelsVisible: true
        )
        sections.append(regularSection)
        return sections.compactMap { $0 }
    }

    private func createProcessedItemContent(
        state: DynamicCheckoutInteractorState.PaymentProcessing, methodId: String
    ) -> DynamicCheckoutViewModelItem? {
        guard let method = state.snapshot.paymentMethods[methodId] else {
            assertionFailure("Unable to resolve payment method by ID")
            return nil
        }
        // todo(andrii-vysotskyi): move submit button to dynamic checkout/card content 
        switch method {
        case .nativeAlternativePayment:
            guard let interactor = state.nativeAlternativePaymentInteractor else {
                assertionFailure("Interactor must be set.")
                return nil
            }
            let item = DynamicCheckoutViewModelItem.AlternativePayment(id: "content_" + methodId) {
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
            let item = DynamicCheckoutViewModelItem.Card(id: "content_" + methodId) {
                let viewModel = DefaultCardTokenizationViewModel(interactor: interactor)
                return AnyCardTokenizationViewModel(erasing: viewModel)
            }
            return .card(item)
        default:
            return nil
        }
    }

    private func createSubmitAction(
        _ state: DynamicCheckoutInteractorState.PaymentProcessing
    ) -> POActionsContainerActionViewModel? {
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
            id: ButtonId.submit,
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
        let section = DynamicCheckoutViewModelSection(
            id: SectionId.default,
            items: [.success(item)],
            areSeparatorsVisible: false,
            areBezelsVisible: false
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
