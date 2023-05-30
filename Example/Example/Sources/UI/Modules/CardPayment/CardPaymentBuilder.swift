//
//  CardPaymentBuilder.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.03.2023.
//

import UIKit
import ProcessOut
import ProcessOutCheckout3DS

final class CardPaymentBuilder {

    func build() -> UIViewController {
        let checkoutDelegate = Checkout3DSServiceDelegate()
        let router = CardPaymentRouter()
        let viewModel = CardPaymentViewModel(
            router: router,
            invoicesService: ProcessOut.shared.invoices,
            cardsService: ProcessOut.shared.cards,
            threeDSService: POCheckout3DSServiceBuilder.with(delegate: checkoutDelegate).build()
        )
        let viewController = CardPaymentViewController(viewModel: viewModel)
        checkoutDelegate.viewController = viewController
        router.viewController = viewController
        return viewController
    }
}

final class Checkout3DSServiceDelegate: POCheckout3DSServiceDelegate {

    unowned var viewController: UIViewController! // swiftlint:disable:this implicitly_unwrapped_optional

    // MARK: - POCheckout3DSServiceDelegate

    func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
        let viewController = PO3DSRedirectViewControllerBuilder
            .with(redirect: redirect)
            .with { [weak self] result in
                self?.viewController.dismiss(animated: true) {
                    completion(result)
                }
            }
            .build()
        self.viewController.present(viewController, animated: true)
    }
}
