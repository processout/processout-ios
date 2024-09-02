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
        let invoiceCreationRequest = POInvoiceCreationRequest(
            name: state.invoice.name,
            amount: state.invoice.amount.description,
            currency: state.invoice.currencyCode.selection,
            returnUrl: Constants.returnUrl,
            customerId: Constants.customerId
        )
        do {
            let invoice = try await self.invoicesService.createInvoice(request: invoiceCreationRequest)
            continueDynamicCheckout(invoice: invoice)
        } catch {
            setMessage(with: error)
        }
    }

    private func continueDynamicCheckout(invoice: POInvoice) {
        let configuration = PODynamicCheckoutConfiguration(
            invoiceRequest: .init(invoiceId: invoice.id, clientSecret: invoice.clientSecret),
            alternativePayment: .init(returnUrl: Constants.returnUrl),
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
        var errorMessage: String?
        if let failure = error as? POFailure {
            guard failure.code != .cancelled else {
                return
            }
            errorMessage = failure.message
        }
        state.message = .init(text: errorMessage ?? String(localized: .DynamicCheckout.errorMessage), severity: .error)
    }
}

extension DynamicCheckoutViewModel: PODynamicCheckoutDelegate {

    func dynamicCheckout(
        willAuthorizeInvoiceWith request: inout POInvoiceAuthorizationRequest
    ) async -> any PO3DSService {
        POTest3DSService(returnUrl: Constants.returnUrl)
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
            amount: invoice.amount.description,
            currency: invoice.currency,
            returnUrl: invoice.returnUrl,
            customerId: Constants.customerId
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
