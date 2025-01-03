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
            paymentMethods: paymentMethodsViewModels,
            isLoading: false,
            message: createMessage(failure: interactorState.recentFailure),
            cancelButton: createCancelButton()
        )
    }

    // MARK: - Removing

    private func update(with interactorState: SavedPaymentMethodsInteractorState.Removing) {
        var removedIds = Set(interactorState.pendingRemovalCustomerTokenIds)
        removedIds.insert(interactorState.removedCustomerTokenId)
        let paymentMethodsViewModels = interactorState.startedStateSnapshot.paymentMethods.map { paymentMethod in
            let isBeingRemoved = removedIds.contains(paymentMethod.customerTokenId)
            return createViewModel(for: paymentMethod, isBeingRemoved: isBeingRemoved)
        }
        state = .init(
            title: createTitle(),
            paymentMethods: paymentMethodsViewModels,
            isLoading: false,
            message: createMessage(failure: interactorState.startedStateSnapshot.recentFailure),
            cancelButton: createCancelButton()
        )
    }

    // MARK: - Utils

    private func createTitle() -> String? {
        String(resource: .SavedPaymentMethods.title)
    }

    private func createViewModel(
        for paymentMethod: SavedPaymentMethodsInteractorState.PaymentMethod, isBeingRemoved: Bool
    ) -> SavedPaymentMethodsViewModelState.PaymentMethod {
        let deleteButton = POButtonViewModel(
            id: "delete-button",
            title: nil,
            icon: Image(poResource: .delete)
                .resizable()
                .renderingMode(.template),
            isLoading: isBeingRemoved,
            confirmation: nil,
            action: { [weak self] in
                self?.interactor.delete(customerTokenId: paymentMethod.customerTokenId)
            }
        )
        let viewModel = SavedPaymentMethodsViewModelState.PaymentMethod(
            id: paymentMethod.customerTokenId,
            logo: paymentMethod.logo,
            name: paymentMethod.name,
            description: paymentMethod.description,
            deleteButton: deleteButton
        )
        return viewModel
    }

    private func createCancelButton() -> POButtonViewModel? {
        let viewModel = POButtonViewModel(
            id: "cancel-button",
            icon: Image(poResource: .close)
                .resizable()
                .renderingMode(.template),
            role: .cancel,
            confirmation: nil,
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
