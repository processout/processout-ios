//
//  SavedPaymentMethodsViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 06.01.2025.
//

import PassKit
import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutUI

@MainActor
final class SavedPaymentMethodsViewModel: ObservableObject {

    init(invoicesService: POInvoicesService) {
        self.invoicesService = invoicesService
    }

    // MARK: -

    @Published
    var state = SavedPaymentMethodsViewModelState()

    func manage() {
        Task { @MainActor in
            await manageSavedPaymentMethods()
        }
        state.message = nil
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService

    // MARK: - Private Methods

    @MainActor
    private func manageSavedPaymentMethods() async {
        do {
            let invoice = try await createInvoice()
            let configuration = POSavedPaymentMethodsConfiguration(
                invoiceRequest: .init(invoiceId: invoice.id, clientSecret: invoice.clientSecret ?? ""),
                cancelButton: .init(confirmation: .init())
            )
            let viewModel = SavedPaymentMethodsViewModelState.SavedPaymentMethods(
                id: UUID().uuidString,
                configuration: configuration,
                completion: { [weak self] result in
                    switch result {
                    case .success:
                        self?.state.message = nil
                    case .failure(let failure):
                        self?.setMessage(with: failure)
                    }
                    self?.state.savedPaymentMethods = nil
                }
            )
            state.savedPaymentMethods = viewModel
        } catch {
            setMessage(with: error)
        }
    }

    private func setMessage(with error: Error) {
        var errorMessage: String?
        if let failure = error as? POFailure {
            guard failure.code != .cancelled else {
                return
            }
            errorMessage = failure.message
        }
        state.message = .init(
            text: errorMessage ?? String(localized: .SavedPaymentMethods.errorMessage), severity: .error
        )
    }

    private func createInvoice() async throws -> POInvoice {
        if state.invoice.id.isEmpty {
            let request = POInvoiceCreationRequest(
                name: UUID().uuidString,
                amount: state.invoice.amount,
                currency: state.invoice.currencyCode,
                returnUrl: Constants.returnUrl,
                customerId: Constants.customerId
            )
            return try await invoicesService.createInvoice(request: request)
        } else {
            let request = POInvoiceRequest(invoiceId: state.invoice.id, attachPrivateKey: true)
            return try await invoicesService.invoice(request: request)
        }
    }
}

extension SavedPaymentMethodsViewModel {

    /// Convenience initializer that resolves its dependencies automatically.
    convenience init() {
        self.init(invoicesService: ProcessOut.shared.invoices)
    }
}
