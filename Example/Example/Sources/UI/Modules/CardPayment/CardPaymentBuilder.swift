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
        let threeDSServiceDelegate = Checkout3DSServiceDelegate()
        let threeDSService = POCheckout3DSServiceBuilder()
            .with(delegate: threeDSServiceDelegate)
            .with(environment: .sandbox)
            .build()
        let router = CardPaymentRouter()
        let viewModel = CardPaymentViewModel(
            router: router,
            invoicesService: ProcessOut.shared.invoices,
            cardsService: ProcessOut.shared.cards,
            threeDSService: threeDSService
        )
        let viewController = CardPaymentViewController(viewModel: viewModel)
        threeDSServiceDelegate.viewController = viewController
        router.viewController = viewController
        return viewController
    }
}

private final class Checkout3DSServiceDelegate: POCheckout3DSServiceDelegate {

    /// View controller to use for presentations.
    unowned var viewController: UIViewController! // swiftlint:disable:this implicitly_unwrapped_optional

    func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
        let viewController = PO3DSRedirectViewControllerBuilder()
            .with(redirect: redirect)
            .with(returnUrl: Constants.returnUrl)
            .with { [weak self] result in
                self?.viewController.dismiss(animated: true) {
                    completion(result)
                }
            }
            .build()
        self.viewController.present(viewController, animated: true)
    }
}
