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
            var invoice: POInvoice! // swiftlint:disable:this implicitly_unwrapped_optional
            let invoiceCreationRequest = POInvoiceCreationRequest(
                name: state.invoice.name,
                amount: state.invoice.amount,
                currency: state.invoice.currencyCode
            )
            let coordinator = ApplePayTokenizationCoordinator { [invoicesService] card in
                invoice = try await invoicesService.createInvoice(request: invoiceCreationRequest)
                let authorizationRequest = POInvoiceAuthorizationRequest(
                    invoiceId: invoice.id, source: card.id
                )
                let threeDSService = POTest3DSService(returnUrl: Constants.returnUrl)
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
