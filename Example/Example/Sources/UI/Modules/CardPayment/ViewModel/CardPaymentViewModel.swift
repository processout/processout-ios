//
//  CardPaymentViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.03.2023.
//

import Foundation
import UIKit
@_spi(PO) import ProcessOut

final class CardPaymentViewModel: BaseViewModel<CardPaymentViewModelState>, CardPaymentViewModelType {

    init(
        router: any RouterType<CardPaymentRoute>,
        invoicesService: POInvoicesServiceType,
        cardsService: POCardsServiceType,
        threeDSService: PO3DSServiceType
    ) {
        self.router = router
        self.invoicesService = invoicesService
        self.cardsService = cardsService
        self.threeDSService = threeDSService
        super.init(state: .idle)
    }

    // MARK: - CardPaymentViewModelType

    override func start() {
        guard case .idle = state else {
            return
        }
        setStartedStateUnchecked()
    }

    func pay() {
        Task {
            await setPayingStateUnchecked()
        }
    }

    // MARK: - Private Nested Types

    private typealias Strings = Example.Strings.CardPayment

    // MARK: - Private Properties

    private let router: any RouterType<CardPaymentRoute>
    private let invoicesService: POInvoicesServiceType
    private let cardsService: POCardsServiceType
    private let threeDSService: PO3DSServiceType

    private let cardNumber = ReferenceTypeBox(value: "")
    private let expirationMonth = ReferenceTypeBox(value: "")
    private let expirationYear = ReferenceTypeBox(value: "")
    private let cvc = ReferenceTypeBox(value: "")
    private let amount = ReferenceTypeBox(value: "")
    private let currencyCode = ReferenceTypeBox(value: "")

    // MARK: - Private Methods

    private func setStartedStateUnchecked() {
        let cardParamters = [
            State.Parameter(
                value: cardNumber,
                placeholder: Strings.Card.number,
                parameterType: .number,
                accessibilityId: "card-payment.card.number"
            ),
            State.Parameter(
                value: expirationMonth,
                placeholder: Strings.Card.expirationMonth,
                parameterType: .number,
                accessibilityId: "card-payment.card.month"
            ),
            State.Parameter(
                value: expirationYear,
                placeholder: Strings.Card.expirationYear,
                parameterType: .number,
                accessibilityId: "card-payment.card.year"
            ),
            State.Parameter(
                value: cvc,
                placeholder: Strings.Card.cvc,
                parameterType: .number,
                accessibilityId: "card-payment.card.cvc"
            )
        ]
        let cardDetailsSection = State.Section(
            identifier: .init(title: Strings.Card.title), parameters: cardParamters
        )
        let invoiceParameters: [State.Parameter] = [
            .init(
                value: amount,
                placeholder: Strings.Invoice.amount,
                parameterType: .number,
                accessibilityId: "card-payment.invoice.amount"
            ),
            .init(
                value: currencyCode,
                placeholder: Strings.Invoice.currency,
                parameterType: .text,
                accessibilityId: "card-payment.invoice.currency"
            )
        ]
        let invoiceSection = State.Section(
            identifier: .init(title: Strings.Invoice.title), parameters: invoiceParameters
        )
        let startedState = State.Started(sections: [cardDetailsSection, invoiceSection])
        state = .started(startedState)
    }

    @MainActor private func setPayingStateUnchecked() async {
        guard let expMonth = Int(expirationMonth.wrappedValue),
              let expYear = Int(expirationYear.wrappedValue) else {
            return
        }
        do {
            let cardTokenizationRequest = POCardTokenizationRequest(
                number: cardNumber.wrappedValue, expMonth: expMonth, expYear: expYear, cvc: cvc.wrappedValue
            )
            let card = try await cardsService.tokenize(request: cardTokenizationRequest)
            let invoiceCreationRequest = POInvoiceCreationRequest(
                name: UUID().uuidString, amount: amount.wrappedValue, currency: currencyCode.wrappedValue
            )
            let invoice = try await invoicesService.createInvoice(request: invoiceCreationRequest)
            let invoiceAuthorizationRequest = POInvoiceAuthorizationRequest(
                invoiceId: invoice.id, source: card.id, enableThreeDS2: true, thirdPartySdkVersion: nil
            )
            try await invoicesService.authorizeInvoice(
                request: invoiceAuthorizationRequest, threeDSHandler: threeDSService
            )
            router.trigger(route: .alert(message: Strings.Result.successMessage(invoice.id, card.id)))
        } catch {
            didFailToAuthorizeInvoice(error: error)
        }
    }

    private func didFailToAuthorizeInvoice(error: Error) {
        let errorDescription: String
        if let failure = error as? POFailure {
            if let message = failure.message {
                errorDescription = Strings.Result.errorMessage(message)
            } else {
                errorDescription = Strings.Result.defaultErrorMessage
            }
        } else {
            errorDescription = Strings.Result.defaultErrorMessage
        }
        router.trigger(route: .alert(message: errorDescription))
    }
}
