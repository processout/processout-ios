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
        let threeDSHandler = TestThreeDSHandler()
        let router = CardPaymentRouter()
        let viewModel = CardPaymentViewModel(
            router: router,
            invoicesService: ProcessOutApi.shared.invoices,
            cardsRepository: ProcessOutApi.shared.cards,
            threeDSHandler: threeDSHandler
        )
        let viewController = CardPaymentViewController(viewModel: viewModel)
        threeDSHandler.viewController = viewController
        router.viewController = viewController
        return viewController
    }
}
