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

@MainActor
@Observable
final class AlternativePaymentsViewModel {

    init(interactor: AlternativePaymentsInteractor) {
        self.interactor = interactor
        observeInteractorStateChanges()
    }

    // MARK: - AlternativePaymentsViewModel

    var state: AlternativePaymentsViewModelState = .idle

    func start() {
        Task {
            await interactor.start()
        }
    }

    func restart() async {
        await interactor.restart()
    }

    // MARK: - Private Properties

    private let interactor: AlternativePaymentsInteractor
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Private Methods

    private func observeInteractorStateChanges() {
        let cancellable = interactor.$state.sink { [weak self] state in
            self?.update(with: state)
        }
        cancellable.store(in: &cancellables)
    }

    private func update(with interactorState: AlternativePaymentsInteractorState) {
        switch interactorState {
        case .idle:
            state = .idle
        case .starting:
            state.sections = []
        case .started(let currentState):
            update(with: currentState, isRestarting: false)
        case .restarting(let snapshot):
            update(with: snapshot, isRestarting: true)
        case .failure(let error):
            update(with: error)
        }
    }

    private func update(with startedState: AlternativePaymentsInteractorState.Started, isRestarting: Bool) {
        let configurationsSection = AlternativePaymentsViewModelState.Section(
            id: "gateway-configurations",
            title: String(localized: .AlternativePayments.gatewayConfigurations),
            items: startedState.gatewayConfigurations.compactMap(createConfigurationItem)
        )
        state.sections = [configurationsSection].filter { !$0.items.isEmpty }
    }

    private func update(with error: Error) {
        let errorMessage: String
        if let failure = error as? POFailure, let message = failure.message {
            errorMessage = message
        } else {
            errorMessage = String(localized: .AlternativePayments.genericError)
        }
        let errorsSection = AlternativePaymentsViewModelState.Section(
            id: "errors",
            title: nil,
            items: [.error(.init(errorMessage: errorMessage))]
        )
        state.sections = [errorsSection]
    }

    // MARK: -

    private func createConfigurationItem(
        with gatewayConfiguration: POGatewayConfiguration
    ) -> AlternativePaymentsViewModelState.Item? {
        guard let gatewayName = gatewayConfiguration.gateway?.displayName else {
            return nil
        }
        let item = AlternativePaymentsViewModelState.ConfigurationItem(
            id: gatewayConfiguration.id,
            name: gatewayName,
            select: { [weak self] in
                // todo(andrii-vysotskyi): start payment
            }
        )
        return .configuration(item)
    }

    // MARK: -

    private func startNativeAlternativePayment(
        amount: Decimal, currencyCode: String, gatewayConfiguration: POGatewayConfiguration
    ) {
        // Invoice is created inside application only for demo purposes. Production application should rely on backend
        // to create invoice. To ensure that customer can't alter such values as amount and currency.
//        interactor.createInvoice(amount: amount, currencyCode: currencyCode) { [weak self, prefersNative] invoice in
//            let route: AlternativePaymentMethodsRoute
//            let isSubaccount = gatewayConfiguration
//                .subAccountsEnabled?
//                .contains(gatewayConfiguration.gatewayName ?? "") ?? false
//            if !isSubaccount {
//                return
//            } else if prefersNative {
//                let paymentRoute = AlternativePaymentMethodsRoute.NativeAlternativePayment(
//                    gatewayConfigurationId: gatewayConfiguration.id,
//                    invoiceId: invoice.id,
//                    completion: { [weak self] result in
//                        self?.didCompleteNativePayment(result: result)
//                    }
//                )
//                route = .nativeAlternativePayment(paymentRoute)
//            } else {
//                let request = POAlternativePaymentMethodRequest(
//                    invoiceId: invoice.id, gatewayConfigurationId: gatewayConfiguration.id
//                )
//                route = .alternativePayment(request: request)
//            }
//            self?.router.trigger(route: route)
//        }
    }

//    private func didCompleteNativePayment(result: Result<Void, POFailure>) {
//        // Success is already a part of native alternative payment module so ignored here.
//        guard case let .failure(failure) = result else {
//            return
//        }
//        let message: String
//        if let failureMessage = failure.message, !failureMessage.isEmpty {
//            var options = String.LocalizationOptions()
//            options.replacements = [failureMessage]
//            message = String(localized: .AlternativePayments.error, options: options)
//        } else {
//            message = String(localized: .AlternativePayments.genericError)
//        }
//        router.trigger(route: .alert(message: message))
//    }
}

extension AlternativePaymentsViewModel {

    /// Convenience initializer that resolves its dependencies automatically.
    convenience init() {
        let interactor = AlternativePaymentsInteractor(
            gatewayConfigurationsRepository: ProcessOut.shared.gatewayConfigurations,
            invoicesService: ProcessOut.shared.invoices
        )
        self.init(interactor: interactor)
    }
}
