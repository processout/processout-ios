//
//  DynamicCheckoutViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.08.2024.
//

import PassKit
import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutUI

@MainActor
final class DynamicCheckoutViewModel: ObservableObject {

    init(invoicesService: POInvoicesService) {
        self.invoicesService = invoicesService
    }

    // MARK: -

    @Published
    var state = DynamicCheckoutViewModelState()

    func pay() {
        Task { @MainActor in
            await startDynamicCheckout()
        }
        state.message = nil
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService

    // MARK: - Private Methods

    @MainActor
    private func startDynamicCheckout() async {
        do {
            let invoice = try await createInvoice()
            continueDynamicCheckout(invoice: invoice)
        } catch {
            setMessage(with: error)
        }
    }

    private func continueDynamicCheckout(invoice: POInvoice) {
        let configuration = PODynamicCheckoutConfiguration(
            invoiceRequest: .init(invoiceId: invoice.id, clientSecret: invoice.clientSecret),
            alternativePayment: .init(
                paymentConfirmation: .init(confirmButton: .init())
            ),
            cancelButton: .init(confirmation: .init())
        )
        let item = DynamicCheckoutViewModelState.DynamicCheckout(
            id: UUID().uuidString,
            configuration: configuration,
            delegate: self,
            completion: { [weak self] result in
                switch result {
                case .success:
                    self?.state.message = .init(
                        text: String(localized: .DynamicCheckout.successMessage, replacements: invoice.id),
                        severity: .success
                    )
                case .failure(let failure):
                    self?.setMessage(with: failure)
                }
                self?.state.dynamicCheckout = nil
            }
        )
        self.state.dynamicCheckout = item
    }

    private func setMessage(with error: Error) {
        let errorMessage: String
        switch error {
        case .Mobile.cancelled, .Customer.cancelled:
            return
        case let failure as POFailure:
            errorMessage = failure.message ?? String(localized: .DynamicCheckout.errorMessage)
        default:
            errorMessage = String(localized: .DynamicCheckout.errorMessage)
        }
        state.message = .init(text: errorMessage, severity: .error)
    }

    private func createInvoice() async throws -> POInvoice {
        if state.invoice.id.isEmpty {
            let request = POInvoiceCreationRequest(
                name: UUID().uuidString,
                amount: state.invoice.amount,
                currency: state.invoice.currencyCode,
                returnUrl: Constants.returnUrl,
                customerId: Constants.customerId,
                details: [
                    .init(name: "Test", amount: state.invoice.amount, quantity: 1)
                ]
            )
            return try await invoicesService.createInvoice(request: request)
        } else {
            let request = POInvoiceRequest(invoiceId: state.invoice.id, attachPrivateKey: true)
            return try await invoicesService.invoice(request: request)
        }
    }
}

extension DynamicCheckoutViewModel: PODynamicCheckoutDelegate {

    func dynamicCheckout(
        willAuthorizeInvoiceWith request: inout POInvoiceAuthorizationRequest,
        using paymentMethod: PODynamicCheckoutPaymentMethod
    ) async -> any PO3DS2Service {
        POTest3DSService()
    }

    func dynamicCheckout(willAuthorizeInvoiceWith request: PKPaymentRequest) async {
        let item = PKPaymentSummaryItem(
            label: "Test",
            amount: state.invoice.amount as NSDecimalNumber // swiftlint:disable:this legacy_objc_type
        )
        request.paymentSummaryItems = [item]
    }

    func dynamicCheckout(
        newInvoiceFor invoice: POInvoice, invalidationReason: PODynamicCheckoutInvoiceInvalidationReason
    ) async -> POInvoiceRequest? {
        let request = POInvoiceCreationRequest(
            name: UUID().uuidString,
            amount: invoice.amount,
            currency: invoice.currency,
            returnUrl: invoice.returnUrl,
            customerId: Constants.customerId,
            details: [
                .init(name: "Test", amount: invoice.amount, quantity: 1)
            ]
        )
        if let invoice = try? await invoicesService.createInvoice(request: request) {
            return .init(invoiceId: invoice.id, clientSecret: invoice.clientSecret)
        }
        return nil
    }
}

extension DynamicCheckoutViewModel {

    /// Convenience initializer that resolves its dependencies automatically.
    convenience init() {
        self.init(invoicesService: ProcessOut.shared.invoices)
    }
}
