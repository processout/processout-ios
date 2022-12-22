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
            let cancelBarButtonItem = UIBarButtonItem(
                systemItem: .cancel,
                primaryAction: .init(handler: { [weak self] _ in
                    self?.viewController?.dismiss(animated: true)
                }),
                menu: nil
            )
            cancelBarButtonItem.tintColor = Asset.Colors.Button.primary.color
            let spaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
            spaceBarButtonItem.width = 18
            viewController.navigationItem.leftBarButtonItems = [spaceBarButtonItem, cancelBarButtonItem]
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
