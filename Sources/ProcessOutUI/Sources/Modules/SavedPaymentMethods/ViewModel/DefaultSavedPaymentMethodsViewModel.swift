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
        state = .init(paymentMethods: [])
    }

    // MARK: - Started

    private func update(with interactorState: SavedPaymentMethodsInteractorState.Started) {
        let paymentMethodsViewModels = interactorState.paymentMethods.map(createViewModel)
        state = .init(paymentMethods: paymentMethodsViewModels)
    }

    // MARK: - Removing

    private func update(with interactorState: SavedPaymentMethodsInteractorState.Removing) {
        let paymentMethodsViewModels = interactorState.startedStateSnapshot.paymentMethods.map(createViewModel)
        state = .init(paymentMethods: paymentMethodsViewModels)
    }

    // MARK: - Utils

    private func createViewModel(
        for paymentMethod: SavedPaymentMethodsInteractorState.PaymentMethod
    ) -> SavedPaymentMethodsViewModelState.PaymentMethod {
        let delete: () -> Void = { [weak self] in
            self?.interactor.delete(customerTokenId: paymentMethod.customerTokenId)
        }
        let viewModel = SavedPaymentMethodsViewModelState.PaymentMethod(
            id: paymentMethod.customerTokenId,
            logo: paymentMethod.logo,
            name: paymentMethod.name,
            description: paymentMethod.description,
            delete: delete
        )
        return viewModel
    }
}
