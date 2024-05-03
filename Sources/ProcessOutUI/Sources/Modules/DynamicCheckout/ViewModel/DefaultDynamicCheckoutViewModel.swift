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

// swiftlint:disable:next type_body_length
final class DefaultDynamicCheckoutViewModel: DynamicCheckoutViewModel {

    init(interactor: some DynamicCheckoutInteractor) {
        self.interactor = interactor
        observeChanges(interactor: interactor)
    }

    // MARK: - DynamicCheckoutViewModel

    @Published
    private(set) var sections: [DynamicCheckoutViewModelSection] = []

    @Published
    private(set) var actions: [POActionsContainerActionViewModel] = []

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
        static let expressMethods = "ExpressMethods"
        static let regularMethods = "RegularMethods"
    }

    // MARK: - Private Properties

    private let interactor: any DynamicCheckoutInteractor

    // MARK: - Interactor Observation

    private func observeChanges(interactor: some Interactor) {
        interactor.didChange = { [weak self] in
            self?.updateWithInteractorState()
        }
    }

    private func updateWithInteractorState() {
        switch interactor.state {
        case .idle, .failure, .success:
            break // Ignored
        case .starting:
            updateWithStartingState()
        case .started(let state):
            updateWithStartedState(state)
        case .selected(let state):
            updateWithSelectedState(state)
        case .paymentProcessing(let state):
            updateWithPaymentProcessingState(state)
        }
    }

    // MARK: - Starting State

    private func updateWithStartingState() {
        let section = DynamicCheckoutViewModelSection(
            id: SectionId.default,
            title: nil,
            items: [.progress],
            areSeparatorsVisible: false,
            areBezelsVisible: false
        )
        sections = [section]
        actions = []
    }

    // MARK: - Started

    private func updateWithStartedState(_ state: DynamicCheckoutInteractorState.Started) {
        updateSectionsWithStartedState(state, selectedMethodId: nil)
        updateActionsWithStartedState(state)
    }

    private func updateSectionsWithStartedState(
        _ state: DynamicCheckoutInteractorState.Started, selectedMethodId: String?
    ) {
        let expressSection = createExpressMethodsSection(state: state)
        let regularItems = state.regularPaymentMethodIds.compactMap { methodId in
            let isSelected = selectedMethodId == methodId
            return createItem(paymentMethodId: methodId, state: state, isExpress: false, isSelected: isSelected)
        }
        let regularSection = DynamicCheckoutViewModelSection(
            id: SectionId.regularMethods,
            title: nil,
            items: regularItems,
            areSeparatorsVisible: true,
            areBezelsVisible: true
        )
        setSections([expressSection, regularSection])
    }

    private func createExpressMethodsSection(
        state: DynamicCheckoutInteractorState.Started
    ) -> DynamicCheckoutViewModelSection {
        let expressItems = state.expressPaymentMethodIds.compactMap { methodId in
            createItem(paymentMethodId: methodId, state: state, isExpress: true, isSelected: false)
        }
        let section = DynamicCheckoutViewModelSection(
            id: SectionId.expressMethods,
            title: String(resource: .DynamicCheckout.Section.expressMethods),
            items: expressItems,
            areSeparatorsVisible: false,
            areBezelsVisible: true
        )
        return section
    }

    private func createItem(
        paymentMethodId methodId: String,
        state: DynamicCheckoutInteractorState.Started,
        isExpress: Bool,
        isSelected: Bool
    ) -> DynamicCheckoutViewModelItem? {
        guard let method = state.paymentMethods[methodId] else {
            assertionFailure("Unable to resolve payment method by ID")
            return nil
        }
        let display: PODynamicCheckoutPaymentMethod.Display
        let isExternal: Bool
        switch method {
        case .applePay:
            let item = DynamicCheckoutViewModelItem.PassKitPayment(id: methodId) { [weak self] in
                self?.interactor.startPayment(methodId: methodId)
            }
            return .passKitPayment(item)
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
        default:
            return nil
        }
        if isExpress {
            return createExpressPaymentItem(id: methodId, display: display)
        }
        return createRegularPaymentItem(id: methodId, display: display, isExternal: isExternal, isSelected: isSelected)
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

    private func createRegularPaymentItem(
        id: String, display: PODynamicCheckoutPaymentMethod.Display, isExternal: Bool, isSelected selected: Bool
    ) -> DynamicCheckoutViewModelItem {
        let isSelected = Binding<Bool> {
            selected
        } set: { [weak self] newValue in
            guard let self, newValue else {
                return
            }
            if isExternal {
                self.interactor.select(paymentMethodId: id)
            } else {
                self.interactor.startPayment(methodId: id)
            }
        }
        var additionalInformation: String?
        if isExternal {
            additionalInformation = String(resource: .DynamicCheckout.redirectWarning)
        }
        let item = DynamicCheckoutViewModelItem.Payment(
            id: id,
            iconImageResource: display.logo,
            brandColor: display.brandColor,
            title: display.name,
            isSelected: isSelected,
            additionalInformation: additionalInformation
        )
        return .payment(item)
    }

    private func updateActionsWithStartedState(_ state: DynamicCheckoutInteractorState.Started) {
        let cancelAction = createCancelAction(state)
        setActions([cancelAction].compactMap { $0 })
    }

    private func createCancelAction(
        _ state: DynamicCheckoutInteractorState.Started
    ) -> POActionsContainerActionViewModel? {
        guard state.isCancellable else {
            return nil
        }
        return createCancelAction(isEnabled: true)
    }

    // MARK: - Selected

    private func updateWithSelectedState(_ state: DynamicCheckoutInteractorState.Selected) {
        updateSectionsWithStartedState(state.snapshot, selectedMethodId: state.paymentMethodId)
        updateActionsWithSelectedState(state)
    }

    private func updateActionsWithSelectedState(_ state: DynamicCheckoutInteractorState.Selected) {
        let submitAction = createSubmitAction(state)
        let cancelAction = createCancelAction(state.snapshot)
        setActions([submitAction, cancelAction].compactMap { $0 })
    }

    private func createSubmitAction(
        _ state: DynamicCheckoutInteractorState.Selected
    ) -> POActionsContainerActionViewModel? {
        let viewModel = POActionsContainerActionViewModel(
            id: ButtonId.submit,
            title: String(resource: .DynamicCheckout.Button.continue),
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
        updateSectionsWithPaymentProcessingState(state)
        updateActionsWithPaymentProcessingState(state)
    }

    private func updateSectionsWithPaymentProcessingState(_ state: DynamicCheckoutInteractorState.PaymentProcessing) {
        let expressSection = createExpressMethodsSection(state: state.snapshot)
        let regularItems = state.snapshot.regularPaymentMethodIds.flatMap { methodId in
            let isProcessing = state.paymentMethodId == methodId
            let item = createItem(
                paymentMethodId: methodId, state: state.snapshot, isExpress: false, isSelected: isProcessing
            )
            guard isProcessing else {
                return [item]
            }
            let itemContent = createProcessedItemContent(state: state.snapshot, methodId: state.paymentMethodId)
            return [item, itemContent]
        }
        let regularSection = DynamicCheckoutViewModelSection(
            id: SectionId.regularMethods,
            title: nil,
            items: regularItems.compactMap { $0 },
            areSeparatorsVisible: true,
            areBezelsVisible: true
        )
        setSections([expressSection, regularSection])
    }

    private func createProcessedItemContent(
        state: DynamicCheckoutInteractorState.Started, methodId: String
    ) -> DynamicCheckoutViewModelItem? {
        guard let method = state.paymentMethods[methodId] else {
            assertionFailure("Unable to resolve payment method by ID")
            return nil
        }
        switch method {
        case .nativeAlternativePayment(let paymentMethod):
            return .alternativePayment(
                .init(gatewayConfigurationId: paymentMethod.configuration.gatewayId)
            )
        case .card:
            return .card
        default:
            return nil
        }
    }

    private func updateActionsWithPaymentProcessingState(_ state: DynamicCheckoutInteractorState.PaymentProcessing) {
        let submitAction = createSubmitAction(state)
        let cancelAction = createCancelAction(state)
        setActions([submitAction, cancelAction].compactMap { $0 })
    }

    private func createSubmitAction(
        _ state: DynamicCheckoutInteractorState.PaymentProcessing
    ) -> POActionsContainerActionViewModel? {
        let isEnabled, isLoading: Bool
        switch state.submission {
        case .unavailable:
            return nil
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
            title: String(resource: .DynamicCheckout.Button.continue),
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
        return createCancelAction(isEnabled: state.isCancellable)
    }

    // MARK: - Utils

    private func createCancelAction(isEnabled: Bool) -> POActionsContainerActionViewModel {
        let viewModel = POActionsContainerActionViewModel(
            id: ButtonId.cancel,
            title: String(resource: .DynamicCheckout.Button.cancel),
            isEnabled: isEnabled,
            isLoading: false,
            isPrimary: false,
            action: { [weak self] in
                self?.interactor.cancel()
            }
        )
        return viewModel
    }

    private func setSections(_ newSections: [DynamicCheckoutViewModelSection]) {
        let newSections = newSections.filter { section in
            !section.items.isEmpty
        }
        let isAnimated = sections.map(\.animationIdentity) != newSections.map(\.animationIdentity)
        withAnimation(isAnimated ? .default : nil) {
            sections = newSections
        }
    }

    private func setActions(_ newActions: [POActionsContainerActionViewModel]) {
        let isAnimated = actions.map(\.id) != newActions.map(\.id)
        withAnimation(isAnimated ? .default : nil) {
            actions = newActions
        }
    }
}
