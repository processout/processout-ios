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
        interactor.start()
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
        updateSectionsWithStartedState(state)
        updateActionsWithStartedState(state)
    }

    private func updateSectionsWithStartedState(_ state: DynamicCheckoutInteractorState.Started) {
        let expressItems = state.expressPaymentMethodIds.compactMap { methodId in
            createItem(paymentMethodId: methodId, state: state, isExpress: true, isProcessing: false)
        }
        let expressSection = DynamicCheckoutViewModelSection(
            id: SectionId.expressMethods,
            title: "Express Methods",
            items: expressItems,
            areSeparatorsVisible: false,
            areBezelsVisible: true
        )
        let regularItems = state.regularPaymentMethodIds.compactMap { methodId in
            createItem(paymentMethodId: methodId, state: state, isExpress: false, isProcessing: false)
        }
        let regularSection = DynamicCheckoutViewModelSection(
            id: SectionId.regularMethods,
            title: nil,
            items: regularItems,
            areSeparatorsVisible: true,
            areBezelsVisible: true
        )
        sections = [expressSection, regularSection].filter { !$0.items.isEmpty }
    }

    private func createItem(
        paymentMethodId methodId: String,
        state: DynamicCheckoutInteractorState.Started,
        isExpress: Bool,
        isProcessing: Bool
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
                self?.interactor.initiatePayment(methodId: methodId)
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
        return createRegularPaymentItem(
            id: methodId, display: display, isExternal: isExternal, isSelected: isProcessing
        )
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
                self?.interactor.initiatePayment(methodId: id)
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
            self.interactor.initiatePayment(methodId: id)
        }
        var additionalInformation: String?
        if isExternal {
            additionalInformation = "You will be redirected to finalise this payment"
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
        guard state.isCancellable else {
            actions = []
            return
        }
        let cancelAction = createCancelAction(isEnabled: true)
        actions = [cancelAction]
    }

    // MARK: - Payment Processing

    private func updateWithPaymentProcessingState(_ state: DynamicCheckoutInteractorState.PaymentProcessing) {
        updateSectionsWithPaymentProcessingState(state)
        updateActionsWithPaymentProcessingState(state)
    }

    private func updateSectionsWithPaymentProcessingState(_ state: DynamicCheckoutInteractorState.PaymentProcessing) {
        let processingPaymentMethodId = state.pendingPaymentMethodId ?? state.paymentMethodId
        let expressItems = state.snapshot.expressPaymentMethodIds.compactMap { methodId in
            let isProcessing = processingPaymentMethodId == methodId
            return createItem(
                paymentMethodId: methodId, state: state.snapshot, isExpress: true, isProcessing: isProcessing
            )
        }
        let expressSection = DynamicCheckoutViewModelSection(
            id: SectionId.expressMethods,
            title: "Express Methods",
            items: expressItems,
            areSeparatorsVisible: false,
            areBezelsVisible: true
        )
        // todo: for card / native APM that are being processed create another item
        let regularItems = state.snapshot.regularPaymentMethodIds.flatMap { methodId in
            let isProcessing = processingPaymentMethodId == methodId
            let item = createItem(
                paymentMethodId: methodId, state: state.snapshot, isExpress: false, isProcessing: isProcessing
            )
            guard isProcessing else {
                return [item]
            }
            switch state.snapshot.paymentMethods[methodId] {
            case .nativeAlternativePayment(let paymentMethod):
                let anotherItem = DynamicCheckoutViewModelItem.alternativePayment(
                    .init(gatewayConfigurationId: paymentMethod.configuration.gatewayId)
                )
                return [item, anotherItem]
            case .card:
                return [item, .card]
            default:
                return [item]
            }
        }
        let regularSection = DynamicCheckoutViewModelSection(
            id: SectionId.regularMethods,
            title: nil,
            items: regularItems.compactMap { $0 },
            areSeparatorsVisible: true,
            areBezelsVisible: true
        )
        sections = [expressSection, regularSection].filter { !$0.items.isEmpty }
    }

    private func updateActionsWithPaymentProcessingState(_ state: DynamicCheckoutInteractorState.PaymentProcessing) {
        let submitAction = createSubmitAction(state)
        let cancelAction = createCancelAction(state)
        actions = [submitAction, cancelAction].compactMap { $0 }
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
            title: String(resource: .DynamicCheckout.Button.submit),
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
}
