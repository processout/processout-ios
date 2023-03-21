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
        let threeDSService = CardPaymentTest3DSService()
        let router = CardPaymentRouter()
        let viewModel = CardPaymentViewModel(
            router: router,
            invoicesService: ProcessOutApi.shared.invoices,
            cardsService: ProcessOutApi.shared.cards,
            threeDSService: threeDSService
        )
        let viewController = CardPaymentViewController(viewModel: viewModel)
        threeDSService.viewController = viewController
        router.viewController = viewController
        return viewController
    }
}
