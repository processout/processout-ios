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

@available(iOS 14, *)
final class DefaultDynamicCheckoutViewModel: ViewModel {

    init(interactor: some DynamicCheckoutInteractor) {
        self.interactor = interactor
        observeChanges(interactor: interactor)
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
            id: SectionId.default, items: [.progress], isTight: false, areBezelsVisible: false
        )
        state = DynamicCheckoutViewModelState(sections: [section], actions: [], isCompleted: false)
    }

    // MARK: - Started

    private func updateWithStartedState(_ state: DynamicCheckoutInteractorState.Started) {
        let newActions = [
            createCancelAction(state)
        ]
        let newState = DynamicCheckoutViewModelState(
            sections: createSectionsWithStartedState(state, selectedMethodId: nil, shouldSaveSelectedMethod: nil),
            actions: newActions.compactMap { $0 },
            isCompleted: false
        )
        self.state = newState
    }

    private func createSectionsWithStartedState(
        _ state: DynamicCheckoutInteractorState.Started, selectedMethodId: String?, shouldSaveSelectedMethod: Bool?
    ) -> [DynamicCheckoutViewModelState.Section] {
        var sections = [
            createErrorSection(state: state),
            createExpressMethodsSection(state: state)
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
            let submitButton = createSubmitAction(methodId: paymentMethod.id, selectedMethodId: selectedMethodId)
            let payment = DynamicCheckoutViewModelItem.RegularPayment(
                id: paymentMethod.id, info: info, content: nil, submitButton: submitButton
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
        let expressItems = state.paymentMethods.filter({ isExpress(paymentMethod: $0) }).compactMap { paymentMethod in
            createExpressPaymentItem(for: paymentMethod, state: state)
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
        for paymentMethod: PODynamicCheckoutPaymentMethod, state: DynamicCheckoutInteractorState.Started
    ) -> DynamicCheckoutViewModelItem? {
        let display: PODynamicCheckoutPaymentMethod.Display
        switch paymentMethod {
        case .applePay:
            return createPassKitPaymentItem(paymentMethodId: paymentMethod.id)
        case .alternativePayment(let paymentMethod):
            display = paymentMethod.display
        case .customerToken(let paymentMethod):
            display = paymentMethod.display
        case .nativeAlternativePayment, .card, .unknown:
            return nil
        }
        let item = DynamicCheckoutViewModelItem.ExpressPayment(
            id: paymentMethod.id,
            title: display.description ?? display.name,
            iconImageResource: display.logo,
            brandColor: display.brandColor,
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
        let display: PODynamicCheckoutPaymentMethod.Display, isExternal: Bool
        switch paymentMethod {
        case .alternativePayment(let paymentMethod):
            display = paymentMethod.display
            isExternal = true
        case .nativeAlternativePayment(let paymentMethod):
            display = paymentMethod.display
            isExternal = false
        case .card(let paymentMethod):
            display = paymentMethod.display
            isExternal = false
        case .customerToken(let paymentMethod):
            display = paymentMethod.display
            isExternal = paymentMethod.configuration.redirectUrl != nil
        case .applePay, .unknown:
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
            return String(resource: .DynamicCheckout.Warning.redirect)
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
            isCompleted: false
        )
        self.state = newState
    }

    private func createSubmitAction(methodId: String, selectedMethodId: String?) -> POButtonViewModel? {
        guard methodId == selectedMethodId else {
            return nil
        }
        let viewModel = POButtonViewModel(
            id: ButtonId.submit,
            title: interactor.configuration.submitButton.title ?? String(resource: .DynamicCheckout.Button.pay),
            icon: interactor.configuration.submitButton.icon,
            role: .primary,
            action: { [weak self] in
                self?.interactor.startPayment(methodId: methodId)
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
        self.state = newState
    }

    private func createSectionsWithPaymentProcessingState(
        _ state: DynamicCheckoutInteractorState.PaymentProcessing
    ) -> [DynamicCheckoutViewModelState.Section] {
        var sections = [
            createErrorSection(state: state.snapshot),
            createExpressMethodsSection(state: state.snapshot)
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
                submitButton: nil
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

    private func createCancelAction(
        _ state: DynamicCheckoutInteractorState.PaymentProcessing
    ) -> POButtonViewModel? {
        guard state.isCancellable || state.snapshot.isCancellable else {
            return nil
        }
        let title: String?, icon: AnyView?, confirmation: POConfirmationDialogConfiguration?
        if state.isAwaitingNativeAlternativePaymentCapture {
            let configuration = interactor.configuration.alternativePayment.paymentConfirmation.cancelButton
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
            isCompleted: false
        )
        self.state = newState
    }

    private func createSectionsWithRestartingState(
        _ state: DynamicCheckoutInteractorState.Restarting
    ) -> [DynamicCheckoutViewModelState.Section] {
        var sections = [
            createErrorSection(state: state.snapshot.snapshot),
            createExpressMethodsSection(state: state.snapshot.snapshot)
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
            id: SectionId.regularMethods, items: regularItems, isTight: true, areBezelsVisible: true
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
        let message = configuration.message ?? String(resource: .DynamicCheckout.successMessage)
        let item = DynamicCheckoutViewModelItem.Success(
            id: ItemId.success,
            message: message,
            image: UIImage(poResource: .success).withRenderingMode(.alwaysTemplate)
        )
        let section = DynamicCheckoutViewModelState.Section(
            id: SectionId.default, items: [.success(item)], isTight: false, areBezelsVisible: false
        )
        state = DynamicCheckoutViewModelState(sections: [section], actions: [], isCompleted: true)
    }

    // MARK: - Utils

    private func createCancelAction(
        title: String?, icon: AnyView?, isEnabled: Bool, confirmation: POConfirmationDialogConfiguration?
    ) -> POButtonViewModel {
        let viewModel = POButtonViewModel(
            id: ButtonId.cancel,
            title: title ?? String(resource: .DynamicCheckout.Button.cancel),
            icon: icon,
            isEnabled: isEnabled,
            role: .cancel,
            confirmation: confirmation.map { configuration in
                .cancel(with: configuration) { [weak self] in self?.interactor.didRequestCancelConfirmation() }
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
            preconditionFailure("Unexpected payment method.")
        }
    }
}

// swiftlint:enable type_body_length
