//
//  CardPaymentBuilder.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.03.2023.
//

import UIKit
import ProcessOut

final class CardPaymentBuilder {

    func build() -> UIViewController {
        let threeDSService = POTest3DSService(returnUrl: Constants.returnUrl)
        let router = CardPaymentRouter()
        let viewModel = CardPaymentViewModel(
            router: router,
            invoicesService: ProcessOut.shared.invoices,
            cardsService: ProcessOut.shared.cards,
            threeDSService: threeDSService
        )
        let viewController = CardPaymentViewController(viewModel: viewModel)
        threeDSService.viewController = viewController
        router.viewController = viewController
        return viewController
    }
}
