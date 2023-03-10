//
//  CardPaymentViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.03.2023.
//

import Foundation
@_spi(PO) import ProcessOut
import UIKit

final class CardPaymentViewModel: BaseViewModel<CardPaymentViewModelState>, CardPaymentViewModelType {

    // MARK: - CardPaymentViewModelType

    unowned var viewController: UIViewController! // swiftlint:disable:this implicitly_unwrapped_optional

    func pay() {
        let cardTokenizationRequest = ProcessOutLegacyApi.Card(
            cardNumber: "4242424242424242",
            expMonth: 12,
            expYear: 2025,
            cvc: "123",
            name: "Andrii"
        )
        ProcessOutLegacyApi.Tokenize(card: cardTokenizationRequest, metadata: nil) { cardId, exception in
            print(exception)
            guard let cardId else {
                assertionFailure("Something went wrong")
                return
            }
            print(cardId)
            let invoiceRequest = POInvoiceCreationRequest(
                name: "Name", amount: "150", currency: "USD"
            )
            ProcessOutApi.shared.invoices.createInvoice(request: invoiceRequest) { [weak self] result in
                guard case let .success(invoice) = result, let self else {
                    return
                }
                let authorizationRequest = AuthorizationRequest(
                    source: cardId, incremental: false, invoiceID: invoice.id
                )
                let handler = ProcessOutLegacyApi.createThreeDSTestHandler(
                    viewController: self.viewController,
                    completion: { source, exception in
                        print(source)
                        print(exception)
                    }
                )
                ProcessOutLegacyApi.makeCardPayment(
                    AuthorizationRequest: authorizationRequest, handler: handler, with: self.viewController
                )
            }
        }
    }
}
