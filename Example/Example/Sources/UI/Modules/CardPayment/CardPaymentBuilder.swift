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
        // swiftlint:disable:next force_unwrapping
        let threeDSService = POTest3DSService(returnUrl: URL(string: "processout-example://return")!)
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
