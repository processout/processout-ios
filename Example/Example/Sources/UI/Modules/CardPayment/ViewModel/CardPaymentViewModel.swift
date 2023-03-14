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

    init(invoicesService: POInvoicesServiceType, cardsRepository: POCardsRepositoryType) {
        self.invoicesService = invoicesService
        self.cardsRepository = cardsRepository
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

    private let invoicesService: POInvoicesServiceType
    private let cardsRepository: POCardsRepositoryType

    private lazy var cardNumber = ValueMutableReferenceBox(value: "")
    private lazy var expirationMonth = ValueMutableReferenceBox(value: "")
    private lazy var expirationYear = ValueMutableReferenceBox(value: "")
    private lazy var cvc = ValueMutableReferenceBox(value: "")

    private lazy var amount = ValueMutableReferenceBox(value: "")
    private lazy var currencyCode = ValueMutableReferenceBox(value: "")

    // MARK: - Private Methods

    private func setStartedStateUnchecked() {
        let cardParamters = [
            State.Parameter(
                value: cardNumber, placeholder: Strings.Card.number, accessibilityId: "card-payment.card.number"
            ),
            State.Parameter(
                value: expirationMonth,
                placeholder: Strings.Card.expirationMonth,
                accessibilityId: "card-payment.card.month"
            ),
            State.Parameter(
                value: expirationYear,
                placeholder: Strings.Card.expirationYear,
                accessibilityId: "card-payment.card.year"
            ),
            State.Parameter(value: cvc, placeholder: Strings.Card.cvc, accessibilityId: "card-payment.card.cvc")
        ]
        let cardDetailsSection = State.Section(
            identifier: .init(title: Strings.Card.title), parameters: cardParamters
        )
//        let invoiceParameters: [State.Parameter] = [
//            .init(
//                value: "",
//                placeholder: Strings.Invoice.amount,
//                accessibilityId: "card-payment.invoice.amount",
//                didChange: { }
//            ),
//            .init(
//                value: "",
//                placeholder: Strings.Invoice.currency,
//                accessibilityId: "card-payment.invoice.currency",
//                didChange: { }
//            )
//        ]
//        let invoiceSection = State.Section(
//            identifier: .init(title: Strings.Invoice.title), parameters: invoiceParameters
//        )
        let startedState = State.Started(sections: [cardDetailsSection])
        state = .started(startedState)
    }

    @MainActor private func setPayingStateUnchecked() async {
        guard let expMonth = Int(expirationMonth.wrappedValue, radix: 10),
              let expYear = Int(expirationYear.wrappedValue, radix: 10) else {
            return
        }
        do {
            let cardTokenizationRequest = POCardTokenizationRequest(
                number: cardNumber.wrappedValue, expMonth: expMonth, expYear: expYear, cvc: cvc.wrappedValue
            )
            let card = try await cardsRepository.tokenize(request: cardTokenizationRequest)
            let invoiceCreationRequest = POInvoiceCreationRequest(
                name: UUID().uuidString, amount: "150", currency: "USD"
            )
            let invoice = try await invoicesService.createInvoice(request: invoiceCreationRequest)
            let invoiceAuthorizationRequest = POInvoiceAuthorizationRequest(
                invoiceId: invoice.id, source: card.id, enableThreeDS2: true, thirdPartySdkVersion: nil
            )
            print(invoiceAuthorizationRequest)
        } catch {
            print(error)
        }
    }
}
