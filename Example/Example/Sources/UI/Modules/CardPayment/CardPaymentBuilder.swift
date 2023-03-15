//
//  CardPaymentBuilder.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.03.2023.
//

import UIKit
@_spi(PO) import ProcessOut

final class CardPaymentBuilder {

    func build() -> UIViewController {
        let api: ProcessOutApiType = ProcessOutApi.shared
        let threeDSHandler = TestThreeDSHandler()
        let viewModel = CardPaymentViewModel(
            invoicesService: api.invoices, cardsRepository: api.cards, threeDSHandler: threeDSHandler
        )
        let viewController = CardPaymentViewController(viewModel: viewModel)
        threeDSHandler.viewController = viewController
        return viewController
    }
}
