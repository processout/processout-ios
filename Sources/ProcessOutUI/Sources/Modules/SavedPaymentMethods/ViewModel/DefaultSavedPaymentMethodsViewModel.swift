//
//  DefaultSavedPaymentMethodsViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

import Foundation
import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
final class DefaultSavedPaymentMethodsViewModel: ViewModel {

    init(interactor: some SavedPaymentMethodsInteractor) {
        self.interactor = interactor
        observeChanges(interactor: interactor)
    }

    deinit {
        Task { @MainActor [interactor] in interactor.cancel() }
    }

    // MARK: - DynamicCheckoutViewModel

    @AnimatablePublished
    var state: SavedPaymentMethodsViewModelState = .idle

    func start() {
        $state.performWithoutAnimation(interactor.start)
    }

    // MARK: - Private Properties

    private let interactor: any SavedPaymentMethodsInteractor

    // MARK: - Interactor Observation

    private func observeChanges(interactor: some Interactor) {
        interactor.didChange = { [weak self] in
            self?.updateWithInteractorState()
        }
        updateWithInteractorState()
    }

    private func updateWithInteractorState() {
        switch interactor.state {
        case .idle, .completed:
            break // Ignored
        case .starting:
            updateWithStartingState()
        case .started(let state):
            update(with: state)
        case .removing(let state):
            update(with: state)
        }
    }

    // MARK: - Starting State

    private func updateWithStartingState() {
        state = .init(
            title: createTitle(),
            isContentUnavailable: false,
            paymentMethods: [],
            isLoading: true,
            message: nil,
            cancelButton: createCancelButton()
        )
    }

    // MARK: - Started

    private func update(with interactorState: SavedPaymentMethodsInteractorState.Started) {
        let paymentMethodsViewModels = interactorState.paymentMethods.map { paymentMethod in
            createViewModel(for: paymentMethod, isBeingRemoved: false)
        }
        state = .init(
            title: createTitle(),
            isContentUnavailable: interactorState.paymentMethods.isEmpty,
            paymentMethods: paymentMethodsViewModels,
            isLoading: false,
            message: createMessage(failure: interactorState.recentFailure),
            cancelButton: createCancelButton()
        )
    }

    // MARK: - Removing

    private func update(with interactorState: SavedPaymentMethodsInteractorState.Removing) {
        var removedIds = Set(interactorState.pendingRemovalCustomerTokenIds)
        removedIds.insert(interactorState.removedPaymentMethod.configuration.customerTokenId)
        let paymentMethodsViewModels = interactorState.startedStateSnapshot.paymentMethods.map { paymentMethod in
            let isBeingRemoved = removedIds.contains(paymentMethod.configuration.customerTokenId)
            return createViewModel(for: paymentMethod, isBeingRemoved: isBeingRemoved)
        }
        state = .init(
            title: createTitle(),
            isContentUnavailable: paymentMethodsViewModels.isEmpty,
            paymentMethods: paymentMethodsViewModels,
            isLoading: false,
            message: createMessage(failure: interactorState.startedStateSnapshot.recentFailure),
            cancelButton: createCancelButton()
        )
    }

    // MARK: - Utils

    private func createTitle() -> String? {
        let title = interactor.configuration.title ?? String(resource: .SavedPaymentMethods.title)
        guard !title.isEmpty else {
            return nil
        }
        return title
    }

    private func createViewModel(
        for paymentMethod: SavedPaymentMethodsInteractorState.PaymentMethod, isBeingRemoved: Bool
    ) -> SavedPaymentMethodsViewModelState.PaymentMethod {
        let viewModel = SavedPaymentMethodsViewModelState.PaymentMethod(
            id: paymentMethod.id,
            logo: paymentMethod.display.logo,
            name: paymentMethod.display.name,
            description: paymentMethod.display.description,
            deleteButton: createDeleteButton(paymentMethod: paymentMethod, isLoading: isBeingRemoved)
        )
        return viewModel
    }

    private func createDeleteButton(
        paymentMethod: SavedPaymentMethodsInteractorState.PaymentMethod, isLoading: Bool
    ) -> POButtonViewModel? {
        guard paymentMethod.configuration.deletingAllowed else {
            return nil
        }
        let configuration = interactor.configuration.paymentMethod.deleteButton.resolved(
            defaultTitle: nil,
            icon: Image(poResource: .delete).resizable().renderingMode(.template)
        )
        let viewModel = POButtonViewModel(
            id: "delete-button",
            title: configuration.title,
            icon: configuration.icon,
            isLoading: isLoading,
            confirmation: configuration.confirmation.map { [weak self] configuration in
                .delete(with: configuration) {
                    self?.interactor.didRequestRemovalConfirmation(
                        customerTokenId: paymentMethod.configuration.customerTokenId
                    )
                }
            },
            action: { [weak self] in
                self?.interactor.delete(customerTokenId: paymentMethod.configuration.customerTokenId)
            }
        )
        return viewModel
    }

    private func createCancelButton() -> POButtonViewModel? {
        let configuration = interactor.configuration.cancelButton?.resolved(
            defaultTitle: nil, icon: Image(poResource: .close).resizable().renderingMode(.template)
        )
        guard let configuration else {
            return nil
        }
        let viewModel = POButtonViewModel(
            id: "cancel-button",
            title: configuration.title,
            icon: configuration.icon,
            role: .cancel,
            confirmation: configuration.confirmation.map { configuration in
                .cancel(with: configuration)
            },
            action: { [weak self] in
                self?.interactor.cancel()
            }
        )
        return viewModel
    }

    private func createMessage(failure: POFailure?) -> POMessage? {
        guard failure != nil else {
            return nil
        }
        return .init(id: "error-message", text: String(resource: .SavedPaymentMethods.genericError), severity: .error)
    }
}
