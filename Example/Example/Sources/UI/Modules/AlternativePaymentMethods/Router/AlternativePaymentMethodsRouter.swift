//
//  AlternativePaymentMethodsRouter.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import UIKit
import ProcessOut

final class AlternativePaymentMethodsRouter: RouterType {

    weak var viewController: UIViewController?

    func trigger(route: AlternativePaymentMethodsRoute) -> Bool {
        switch route {
        case let .nativeAlternativePayment(gatewayConfigurationId, invoiceId):
            let viewController = PONativeAlternativePaymentMethodViewControllerBuilder
                .with(invoiceId: invoiceId, gatewayConfigurationId: gatewayConfigurationId)
                .with(completion: { [weak self] _ in
                    self?.viewController?.dismiss(animated: true)
                })
                .build()
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.navigationBar.prefersLargeTitles = false
            self.viewController?.present(navigationController, animated: true)
        case let .authorizationtAmount(completion):
            let viewController = AuthorizationAmountBuilder(completion: completion).build()
            self.viewController?.present(viewController, animated: true)
        }
        return true
    }
}
