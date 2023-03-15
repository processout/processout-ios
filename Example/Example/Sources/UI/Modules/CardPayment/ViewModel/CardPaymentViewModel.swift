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
        invoicesService: POInvoicesServiceType,
        cardsRepository: POCardsRepositoryType,
        threeDSHandler: POThreeDSHandlerType
    ) {
        self.invoicesService = invoicesService
        self.cardsRepository = cardsRepository
        self.threeDSHandler = threeDSHandler
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
    private let threeDSHandler: POThreeDSHandlerType

    private lazy var cardNumber = ReferenceTypeBox(value: "")
    private lazy var expirationMonth = ReferenceTypeBox(value: "")
    private lazy var expirationYear = ReferenceTypeBox(value: "")
    private lazy var cvc = ReferenceTypeBox(value: "")

    private lazy var amount = ReferenceTypeBox(value: "")
    private lazy var currencyCode = ReferenceTypeBox(value: "")

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
            let card = try await cardsRepository.tokenize(request: cardTokenizationRequest)
            let invoiceCreationRequest = POInvoiceCreationRequest(
                name: UUID().uuidString, amount: amount.wrappedValue, currency: currencyCode.wrappedValue
            )
            let invoice = try await invoicesService.createInvoice(request: invoiceCreationRequest)
            let invoiceAuthorizationRequest = POInvoiceAuthorizationRequest(
                invoiceId: invoice.id, source: card.id, enableThreeDS2: true, thirdPartySdkVersion: nil
            )
            try await invoicesService.authorizeInvoice(
                request: invoiceAuthorizationRequest, threeDSHandler: threeDSHandler
            )
            print("Show success alert")
        } catch {
            print(error)
        }
    }
}
