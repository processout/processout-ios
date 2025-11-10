//
//  CardPaymentViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.08.2024.
//

import Combine
import SwiftUI
@_spi(PO) import ProcessOut
import ProcessOutUI
import ProcessOutCheckout3DS
import ProcessOutNetcetera3DS
import Checkout3DS

@MainActor
final class CardPaymentViewModel: ObservableObject {

    init(invoicesService: POInvoicesService) {
        self.invoicesService = invoicesService
    }

    // MARK: -

    @Published
    var state = CardPaymentViewModelState()

    func pay() {
        state.message = nil
        setCardTokenizationItem()
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService

    // MARK: - Private Methods

    private func setCardTokenizationItem() {
        let configuration = POCardTokenizationConfiguration(
            cardholderName: nil,
            isSavingAllowed: true,
            cancelButton: .init(icon: Image(systemName: "xmark"))
        )
        let cardTokenizationItem = CardPaymentViewModelState.CardTokenization(
            id: UUID().uuidString,
            configuration: configuration,
            delegate: self,
            completion: { [weak self] result in
                switch result {
                case .success(let card):
                    self?.state.message = .init(
                        text: String(localized: .CardPayment.successMessage, replacements: card.id),
                        severity: .success
                    )
                case .failure:
                    break // Ignored
                }
                self?.state.cardTokenization = nil
            }
        )
        state.cardTokenization = cardTokenizationItem
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

extension CardPaymentViewModel: POCardTokenizationDelegate {

    func cardTokenization(didTokenizeCard card: POCard, shouldSaveCard save: Bool) async throws {
        let invoice = try await createInvoice()
        let invoiceAuthorizationRequest = POInvoiceAuthorizationRequest(
            invoiceId: invoice.id,
            source: card.id,
            saveSource: save,
            clientSecret: invoice.clientSecret
        )
        let threeDSService: PO3DS2Service
        switch state.authenticationService.selection {
        case .test:
            threeDSService = POTest3DSService()
        case .checkout:
            let delegate = DefaultCheckout3DSDelegate()
            threeDSService = POCheckout3DSService(delegate: delegate, environment: .sandbox)
        case .netcetera:
            let configuration = PONetcetera3DS2ServiceConfiguration(returnUrl: Constants.returnUrl)
            threeDSService = PONetcetera3DS2Service(configuration: configuration)
        }
        try await invoicesService.authorizeInvoice(request: invoiceAuthorizationRequest, threeDSService: threeDSService)
    }
}

final class DefaultCheckout3DSDelegate: POCheckout3DSServiceDelegate {

    init() { }

    // MARK: - POCheckout3DSServiceDelegate

    func checkout3DSService(
        _ service: POCheckout3DSService,
        configurationWith parameters: ThreeDS2ServiceConfiguration.ConfigParameters
    ) -> ThreeDS2ServiceConfiguration? {
        .init(configParameters: parameters, appURL: Constants.returnUrl)
    }
}

extension CardPaymentViewModel {

    /// Convenience initializer that resolves its dependencies automatically.
    convenience init() {
        self.init(invoicesService: ProcessOut.shared.invoices)
    }
}
