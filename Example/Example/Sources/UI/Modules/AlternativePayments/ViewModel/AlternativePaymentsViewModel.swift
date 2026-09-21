//
//  AlternativePaymentsViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import Foundation
import Combine
import SwiftUI
@_spi(PO) import ProcessOut
import ProcessOutUI

@MainActor
final class AlternativePaymentsViewModel: ObservableObject {

    init(interactor: AlternativePaymentsInteractor) {
        self.interactor = interactor
        cancellables = []
        observeInteractorStateChanges()
        updateStateFlows()
        updateStateFinalizationModes()
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
        let errorMessage: String
        switch error {
        case let failure as POFailure:
            errorMessage = failure.message ?? String(localized: .AlternativePayments.errorMessage)
        default:
            errorMessage = String(localized: .AlternativePayments.errorMessage)
        }
        state.message = .init(text: errorMessage, severity: .error)
    }

    private func updateStateFlows() {
        let flows: [AlternativePaymentsViewModelState.Flow] = [
            .payment, .tokenization, .combined
        ]
        state.flow = .init(sources: flows, id: \.self, selection: .payment)
    }

    private func updateStateFinalizationModes() {
        let modes: [AlternativePaymentsViewModelState.FinalizationMode] = [.automatic, .authorization, .capture]
        state.finalizationMode = .init(sources: modes, id: \.self, selection: .automatic)
    }

    // MARK: -

    // swiftlint:disable:next function_body_length
    private func startPayment() async {
        guard let gatewayConfigurationId = state.gatewayConfiguration?.selection else {
            return
        }
        do {
            let invoice = if state.invoice.id.isEmpty {
                try await interactor.createInvoice(
                    amount: state.invoice.amount,
                    currencyCode: state.invoice.currencyCode,
                    paymentConfiguration: paymentConfiguration(
                        with: state.finalizationMode.selection
                    )
                )
            } else {
                try await interactor.invoice(id: state.invoice.id)
            }
            var authorizationSource = gatewayConfigurationId
            switch state.flow.selection {
            case .payment where state.preferNative:
                let flow = PONativeAlternativePaymentConfiguration.Flow.authorization(
                    .init(invoiceId: invoice.id, gatewayConfigurationId: gatewayConfigurationId)
                )
                try await authorizeNatively(invoice: invoice, flow: flow)
            case .payment:
                try await interactor.authorize(
                    invoice: invoice, gatewayConfigurationId: gatewayConfigurationId, saveSource: false
                )
            case .tokenization where state.preferNative:
                let token = try await interactor.createToken()
                let flow = PONativeAlternativePaymentConfiguration.Flow.tokenization(
                    .init(
                        customerId: token.customerId,
                        customerTokenId: token.id,
                        gatewayConfigurationId: gatewayConfigurationId
                    )
                )
                try await authorizeNatively(invoice: invoice, flow: flow)
            case .tokenization:
                let token = try await interactor.tokenize(gatewayConfigurationId: gatewayConfigurationId)
                try await interactor.authorize(invoice: invoice, customerToken: token)
                authorizationSource = token.id
            case .combined:
                try await interactor.authorize(
                    invoice: invoice, gatewayConfigurationId: gatewayConfigurationId, saveSource: true
                )
            }
            let successMessage = String(
                localized: .AlternativePayments.successMessage, replacements: invoice.id, authorizationSource
            )
            state.message = .init(text: successMessage, severity: .success)
        } catch {
            updateStateMessage(with: error)
        }
    }

    private func paymentConfiguration(
        with finalizationMode: AlternativePaymentsViewModelState.FinalizationMode
    ) -> POInvoiceCreationRequest.PaymentConfiguration {
        switch finalizationMode {
        case .automatic:
            .init(apm: .init(preferredFinalizationMode: .automatic))
        case .authorization, .capture:
            .init(apm: .init(preferredFinalizationMode: .manual))
        }
    }

    private func authorizeNatively(
        invoice: POInvoice, flow: PONativeAlternativePaymentConfiguration.Flow
    ) async throws {
        let configuration = PONativeAlternativePaymentConfiguration(
            flow: flow,
            header: .automatic,
            redirect: .init(enableHeadlessMode: true),
            cancelButton: .init(
                confirmation: .init()
            ),
            paymentConfirmation: .init(
                showProgressViewAfter: 5, confirmButton: .init(), cancelButton: .init(disabledFor: 10)
            )
        )
        let delegate = NativeAlternativePaymentDelegate(
            invoiceId: invoice.id,
            finalizationMode: state.finalizationMode.selection,
            interactor: interactor
        )
        var continuation: CheckedContinuation<Void, any Error>?, result: Result<Void, POFailure>?
        let component = PONativeAlternativePaymentComponent(
            configuration: configuration, delegate: delegate
        ) { [weak self] paymentResult in
            self?.state.nativePayment = nil
            continuation?.resume(with: paymentResult)
            result = paymentResult
        }
        await component.start()
        if let result {
            try result.get()
            return
        }
        try await withCheckedThrowingContinuation { newContinuation in
            continuation = newContinuation
            state.nativePayment = .init(id: UUID().uuidString, component: component)
        }
        withExtendedLifetime(delegate) { } // Ensure delegate is kept alive for a duration of the payment
    }
}

@MainActor
private final class NativeAlternativePaymentDelegate: PONativeAlternativePaymentDelegateV2 {

    init(
        invoiceId: String,
        finalizationMode: AlternativePaymentsViewModelState.FinalizationMode,
        interactor: AlternativePaymentsInteractor
    ) {
        self.invoiceId = invoiceId
        self.finalizationMode = finalizationMode
        self.interactor = interactor
    }

    // MARK: - PONativeAlternativePaymentDelegateV2

    func nativeAlternativePayment(didEmitEvent event: PONativeAlternativePaymentEventV2) {
        // Ignored
    }

    func nativeAlternativePayment(
        defaultValuesFor parameters: [PONativeAlternativePaymentFormV2.Parameter]
    ) async -> [String: PONativeAlternativePaymentParameterValue] {
        [:]
    }

    func nativeAlternativePayment(
        finalizeWith availableActions: [PONativeAlternativePaymentAvailableActionV2]
    ) async throws(POFailure) {
        do {
            switch finalizationMode {
            case .automatic:
                throw POFailure(
                    message: "Payment with automatic finalization mode is not expected to be finalized manually.",
                    code: .Mobile.generic
                )
            case .authorization:
                guard availableActions.contains(.authorize) else {
                    throw POFailure(message: "Authorization is not available.", code: .Mobile.generic)
                }
                try await interactor.authorize(invoiceId: invoiceId)
            case .capture:
                guard availableActions.contains(.capture) else {
                    throw POFailure(message: "Capture is not available.", code: .Mobile.generic)
                }
                try await interactor.capture(invoiceId: invoiceId)
            }
        } catch let failure as POFailure {
            throw failure
        } catch {
            throw POFailure(
                message: "Unable to finalize payment.", code: .Mobile.generic, underlyingError: error
            )
        }
    }

    // MARK: - Private Properties

    private let invoiceId: String
    private let finalizationMode: AlternativePaymentsViewModelState.FinalizationMode
    private let interactor: AlternativePaymentsInteractor
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
