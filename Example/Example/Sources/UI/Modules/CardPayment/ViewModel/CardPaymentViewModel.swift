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

    func pay() {
        let cardTokenizationRequest = POCardTokenizationRequest(
            number: "4242424242424242", expMonth: 12, expYear: 2025, cvc: "123"
        )
        cardsRepository.tokenize(request: cardTokenizationRequest) { result in
            switch result {
            case .success(let card):
                print(card.id)
            case .failure(let failure):
                print(failure)
            }
        }
        let invoiceCreationRequest = POInvoiceCreationRequest(
            name: UUID().uuidString, amount: "150", currency: "USD"
        )
        invoicesService.createInvoice(request: invoiceCreationRequest) { result in
            switch result {
            case .success(let invoice):
                print(invoice.id)
            case .failure(let failure):
                print(failure)
            }
        }
        let invoiceAuthorizationRequest = POInvoiceAuthorizationRequest(
            invoiceId: "invoice.id",
            source: "card.id",
            enableThreeDS2: true,
            thirdPartySdkVersion: "3.0.0"
        )
        print(invoiceAuthorizationRequest)
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesServiceType
    private let cardsRepository: POCardsRepositoryType

    // MARK: - Private Methods
}
