//
//  AlternativePaymentsViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import Foundation
import Combine
import SwiftUI
import ProcessOut
import ProcessOutUI

@MainActor
final class AlternativePaymentsViewModel: ObservableObject {

    init(interactor: AlternativePaymentsInteractor) {
        self.interactor = interactor
        cancellables = []
        observeInteractorStateChanges()
    }

    // MARK: - AlternativePaymentsViewModel

    @Published
    var state = AlternativePaymentsViewModelState()

    func start() {
        Task {
            await interactor.start()
        }
    }

    func restart() async {
        state.nativePayment = nil
        state.message = nil
        await interactor.restart()
    }

    func pay() {
        state.nativePayment = nil
        state.message = nil
        Task {
            await startPayment()
        }
    }

    // MARK: - Private Properties

    private let interactor: AlternativePaymentsInteractor
    private var cancellables: Set<AnyCancellable>

    // MARK: - Interactor Observation

    private func observeInteractorStateChanges() {
        let cancellable = interactor.$state.sink { [weak self] state in
            self?.update(with: state)
        }
        cancellables.insert(cancellable)
    }

    private func update(with interactorState: AlternativePaymentsInteractorState) {
        switch interactorState {
        case .idle:
            state.filter = nil
            state.gatewayConfiguration = nil
        case .starting(let interactorState):
            updateStateFilters(with: interactorState.filter)
            state.gatewayConfiguration = nil
        case .started(let interactorState):
            updateStateFilters(with: interactorState.filter)
            updateStateGatewayConfigurations(with: interactorState.gatewayConfigurations)
        case .failure(let failure):
            state.gatewayConfiguration = nil
            state.filter = nil
            updateStateMessage(with: failure)
        }
    }

    private func updateStateFilters(with selectedFilter: POAllGatewayConfigurationsRequest.Filter) {
        let sources: [AlternativePaymentsViewModelState.Filter] = [
            .init(id: .alternativePaymentMethods, name: String(localized: .AlternativePayments.Filter.all)),
            .init(
                id: .alternativePaymentMethodsWithTokenization,
                name: String(localized: .AlternativePayments.Filter.tokenizable)
            ),
            .init(id: .nativeAlternativePaymentMethods, name: String(localized: .AlternativePayments.Filter.native))
        ]
        let binding = Binding(
            get: {
                PickerData(sources: sources, id: \.id, selection: selectedFilter)
            },
            set: { [weak self] newValue in
                Task { @MainActor in
                    await self?.interactor.setFilter(newValue.selection)
                }
            }
        )
        state.filter = binding
    }

    private func updateStateGatewayConfigurations(with gatewayConfigurations: [POGatewayConfiguration]) {
        if gatewayConfigurations.isEmpty {
            state.gatewayConfiguration = nil
        } else {
            let sources = gatewayConfigurations.map { configuration in
                AlternativePaymentsViewModelState.GatewayConfiguration(
                    id: configuration.id, name: configuration.gateway?.name ?? ""
                )
            }
            // swiftlint:disable:next force_unwrapping
            let selection = state.gatewayConfiguration?.selection ?? gatewayConfigurations.first!.id
            state.gatewayConfiguration = .init(sources: sources, id: \.id, selection: selection)
        }
    }

    private func updateStateMessage(with error: Error) {
        if let failure = error as? POFailure, failure.code == .cancelled {
            return
        }
        let errorMessage: String
        if let failure = error as? POFailure, let message = failure.message {
            errorMessage = message
        } else {
            errorMessage = String(localized: .AlternativePayments.errorMessage)
        }
        state.message = .init(text: errorMessage, severity: .error)
    }

    // MARK: -

    private func startPayment() async {
        guard let gatewayConfigurationId = state.gatewayConfiguration?.selection else {
            return
        }
        do {
            let invoice = try await interactor.createInvoice(
                name: state.invoice.name,
                amount: state.invoice.amount,
                currencyCode: state.invoice.currencyCode
            )
            var authorizationSource = gatewayConfigurationId
            if state.preferNative {
                try await authorizeNatively(invoice: invoice, gatewayConfigurationId: gatewayConfigurationId)
            } else if state.shouldTokenize {
                let token = try await interactor.tokenize(gatewayConfigurationId: gatewayConfigurationId)
                try await interactor.authorize(invoice: invoice, customerToken: token)
                authorizationSource = token.id
            } else {
                try await interactor.authorize(invoice: invoice, gatewayConfigurationId: gatewayConfigurationId)
            }
            let successMessage = String(
                localized: .AlternativePayments.successMessage, replacements: invoice.id, authorizationSource
            )
            state.message = .init(text: successMessage, severity: .success)
        } catch {
            updateStateMessage(with: error)
        }
    }

    private func authorizeNatively(invoice: POInvoice, gatewayConfigurationId: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            let configuration = PONativeAlternativePaymentConfiguration(
                invoiceId: invoice.id,
                gatewayConfigurationId: gatewayConfigurationId,
                secondaryAction: .cancel(),
                paymentConfirmation: .init(
                    showProgressIndicatorAfter: 5,
                    secondaryAction: .cancel(disabledFor: 10)
                )
            )
            let nativePaymentItem = AlternativePaymentsViewModelState.NativePayment(
                id: UUID().uuidString,
                configuration: configuration,
                completion: { [weak self] result in
                    self?.state.nativePayment = nil
                    continuation.resume(with: result)
                }
            )
            state.nativePayment = nativePaymentItem
        }
    }
}

extension AlternativePaymentsViewModel {

    /// Convenience initializer that resolves its dependencies automatically.
    convenience init() {
        let interactor = AlternativePaymentsInteractor(
            gatewayConfigurationsRepository: ProcessOut.shared.gatewayConfigurations,
            invoicesService: ProcessOut.shared.invoices,
            alternativePaymentsService: ProcessOut.shared.alternativePayments,
            tokensService: ProcessOut.shared.customerTokens
        )
        self.init(interactor: interactor)
    }
}
