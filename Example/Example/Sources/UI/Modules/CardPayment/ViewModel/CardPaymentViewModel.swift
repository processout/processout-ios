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

@MainActor
final class CardPaymentViewModel: ObservableObject {

    init(invoicesService: POInvoicesService) {
        self.invoicesService = invoicesService
        commonInit()
    }

    // MARK: -

    @Published
    var state: CardPaymentViewModelState! // swiftlint:disable:this implicitly_unwrapped_optional

    func pay() {
        state.message = nil
        setCardTokenizationItem()
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService

    // MARK: - Private Methods

    private func commonInit() {
        state = .init(
            authenticationService: .init(
                sources: [.test, .checkout], id: \.self, selection: .test
            ),
            cardTokenization: nil
        )
    }

    private func setCardTokenizationItem() {
        let configuration = POCardTokenizationConfiguration(isCardholderNameInputVisible: false)
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
                returnUrl: Constants.returnUrl
            )
            return try await invoicesService.createInvoice(request: request)
        } else {
            let request = POInvoiceRequest(invoiceId: state.invoice.id)
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
        let threeDSService: PO3DSService
        switch state.authenticationService.selection {
        case .test:
            threeDSService = POTest3DSService(returnUrl: Constants.returnUrl)
        case .checkout:
            threeDSService = POCheckout3DSServiceBuilder()
                .with(delegate: self)
                .with(environment: .sandbox)
                .build()
        }
        try await invoicesService.authorizeInvoice(request: invoiceAuthorizationRequest, threeDSService: threeDSService)
    }
}

extension CardPaymentViewModel: POCheckout3DSServiceDelegate {

    func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
        Task { @MainActor in
            let session = POWebAuthenticationSession(
                redirect: redirect, returnUrl: Constants.returnUrl, completion: completion
            )
            if await session.start() {
                return
            }
            let failure = POFailure(message: "Unable to process redirect", code: .generic(.mobile))
            completion(.failure(failure))
        }
    }
}

extension CardPaymentViewModel {

    /// Convenience initializer that resolves its dependencies automatically.
    convenience init() {
        self.init(invoicesService: ProcessOut.shared.invoices)
    }
}
