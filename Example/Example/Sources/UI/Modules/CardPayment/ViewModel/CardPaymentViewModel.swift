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

@Observable
final class CardPaymentViewModel {

    init(invoicesService: POInvoicesService) {
        self.invoicesService = invoicesService
        commonInit()
    }

    // MARK: -

    var state: CardPaymentViewModelState! // swiftlint:disable:this implicitly_unwrapped_optional

    func pay() {
        setCardTokenizationItem()
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService

    // MARK: - Private Methods

    private func commonInit() {
        state = .init(
            invoice: .init(
                name: UUID().uuidString,
                currencyCode: .init(sources: Locale.Currency.isoCurrencies, id: \.identifier, selection: "USD")
            ),
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
            completion: { [weak self] _ in
                // todo(andrii-vysotskyi): present success/error message
                self?.state.cardTokenization = nil
            }
        )
        state.cardTokenization = cardTokenizationItem
    }
}

extension CardPaymentViewModel: POCardTokenizationDelegate {

    func cardTokenization(didTokenizeCard card: POCard, shouldSaveCard save: Bool) async throws {
        let invoiceCreationRequest = POInvoiceCreationRequest(
            name: state.invoice.name,
            amount: state.invoice.amount,
            currency: state.invoice.currencyCode.selection,
            returnUrl: Constants.returnUrl
        )
        let invoice = try await invoicesService.createInvoice(request: invoiceCreationRequest)
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
