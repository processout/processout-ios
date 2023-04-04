//
//  CardPaymentBuilder.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.03.2023.
//

import UIKit
import ProcessOut
import ProcessOutCheckout

final class CardPaymentBuilder {

    func build() -> UIViewController {
        let delegate = ProcessOutCheckout3DSServiceDelegate()
        let threeDSService = POCheckout3DSServiceBuilder.with(delegate: delegate).build()
        let router = CardPaymentRouter()
        let viewModel = CardPaymentViewModel(
            router: router,
            invoicesService: ProcessOutApi.shared.invoices,
            cardsService: ProcessOutApi.shared.cards,
            threeDSService: threeDSService
        )
        let viewController = CardPaymentViewController(viewModel: viewModel)
        delegate.viewController = viewController
        router.viewController = viewController
        return viewController
    }
}

final class ProcessOutCheckout3DSServiceDelegate: POCheckout3DSServiceDelegate {

    /// View controller to use for presentations.
    unowned var viewController: UIViewController! // swiftlint:disable:this implicitly_unwrapped_optional

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
