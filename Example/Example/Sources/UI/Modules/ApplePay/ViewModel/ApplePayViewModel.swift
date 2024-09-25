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

    init(invoicesService: POInvoicesService, cardsService: POCardsService) {
        self.invoicesService = invoicesService
        self.cardsService = cardsService
    }

    // MARK: -

    @Published
    var state = ApplePayViewModelState()

    func pay() {
        state.message = nil
        Task {
            await startPassKitPayment()
        }
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService
    private let cardsService: POCardsService

    // MARK: - Private Methods

    func startPassKitPayment() async {
        let request = PKPaymentRequest()
        request.merchantIdentifier = Constants.merchantId ?? ""
        request.merchantCapabilities = [.threeDSecure]
        request.paymentSummaryItems = [
            // swiftlint:disable:next legacy_objc_type
            .init(label: "Test", amount: state.invoice.amount as NSDecimalNumber)
        ]
        request.currencyCode = state.invoice.currencyCode
        request.countryCode = "US"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        await createInvoiceAndAuthorize(request: request)
    }

    private func createInvoiceAndAuthorize(request: PKPaymentRequest) async {
        do {
            let invoice = try await createInvoice()
            let coordinator = ApplePayTokenizationCoordinator { [invoicesService] card in
                let authorizationRequest = POInvoiceAuthorizationRequest(
                    invoiceId: invoice.id, source: card.id
                )
                let threeDSService = POTest3DSService()
                try await invoicesService.authorizeInvoice(
                    request: authorizationRequest, threeDSService: threeDSService
                )
            }
            let tokenizationRequest = POApplePayTokenizationRequest(paymentRequest: request)
            let card = try await cardsService.tokenize(request: tokenizationRequest, delegate: coordinator)
            setSuccessMessage(invoice: invoice, card: card)
        } catch {
            state.message = .init(text: String(localized: .ApplePay.errorMessage), severity: .error)
        }
    }

    private func createInvoice() async throws -> POInvoice {
        if state.invoice.id.isEmpty {
            let request = POInvoiceCreationRequest(
                name: UUID().uuidString,
                amount: state.invoice.amount,
                currency: state.invoice.currencyCode,
                returnUrl: Constants.returnUrl
            )
            return try await invoicesService.createInvoice(request: request)
        } else {
            let request = POInvoiceRequest(invoiceId: state.invoice.id, attachPrivateKey: true)
            return try await invoicesService.invoice(request: request)
        }
    }

    private func setSuccessMessage(invoice: POInvoice, card: POCard) {
        let text = String(localized: .ApplePay.successMessage, replacements: invoice.id, card.id)
        state.message = .init(text: text, severity: .success)
    }
}

extension ApplePayViewModel {

    /// Convenience initializer that resolves its dependencies automatically.
    convenience init() {
        self.init(invoicesService: ProcessOut.shared.invoices, cardsService: ProcessOut.shared.cards)
    }
}
