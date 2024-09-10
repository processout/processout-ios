//
//  ApplePayViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.08.2024.
//

import PassKit
import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutUI

@MainActor
final class ApplePayViewModel: ObservableObject {

    init(invoicesService: POInvoicesService) {
        self.invoicesService = invoicesService
    }

    // MARK: -

    @Published
    var state = ApplePayViewModelState()

    func pay() {
        state.message = nil
        startPassKitPayment()
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService

    // MARK: - Private Methods

    func startPassKitPayment() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = Constants.merchantId ?? ""
        request.merchantCapabilities = [.threeDSecure]
        request.paymentSummaryItems = [
            // swiftlint:disable:next legacy_objc_type
            .init(label: "Test", amount: state.invoice.amount as NSDecimalNumber)
        ]
        request.currencyCode = state.invoice.currencyCode.selection
        request.countryCode = "US"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        guard let controller = POPassKitPaymentAuthorizationController(paymentRequest: request) else {
            assertionFailure("Unable to start PassKit payment authorization.")
            return
        }
        controller.delegate = self
        controller.present()
    }
}

extension ApplePayViewModel: POPassKitPaymentAuthorizationControllerDelegate {

    func paymentAuthorizationControllerDidFinish(_ controller: POPassKitPaymentAuthorizationController) {
        controller.dismiss()
    }

    func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didTokenizePayment payment: PKPayment,
        card: POCard
    ) async -> PKPaymentAuthorizationResult {
        let invoiceCreationRequest = POInvoiceCreationRequest(
            name: state.invoice.name,
            amount: state.invoice.amount.description,
            currency: state.invoice.currencyCode.selection
        )
        do {
            let invoice = try await invoicesService.createInvoice(request: invoiceCreationRequest)
            let authorizationRequest = POInvoiceAuthorizationRequest(
                invoiceId: invoice.id, source: card.id
            )
            let threeDSService = POTest3DSService()
            try await invoicesService.authorizeInvoice(request: authorizationRequest, threeDSService: threeDSService)
            setSuccessMessage(invoice: invoice, card: card)
        } catch {
            return .init(status: .failure, errors: [error])
        }
        return .init(status: .success, errors: nil)
    }

    // MARK: - Private Methods

    private func setSuccessMessage(invoice: POInvoice, card: POCard) {
        let text = String(localized: .ApplePay.successMessage, replacements: invoice.id, card.id)
        state.message = .init(text: text, severity: .success)
    }
}

extension ApplePayViewModel {

    /// Convenience initializer that resolves its dependencies automatically.
    convenience init() {
        self.init(invoicesService: ProcessOut.shared.invoices)
    }
}
