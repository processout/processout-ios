//
//  AlternativePaymentMethodsRouter.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import UIKit
@_spi(PO) import ProcessOut

final class AlternativePaymentMethodsRouter: RouterType {

    weak var viewController: UIViewController?

    func trigger(route: AlternativePaymentMethodsRoute) -> Bool {
        switch route {
        case let .nativeAlternativePayment(gatewayConfigurationId, invoiceId):
            let viewController = PONativeAlternativePaymentMethodViewControllerBuilder
                .with(invoiceId: invoiceId, gatewayConfigurationId: gatewayConfigurationId)
                .with { [weak self] _ in
                    self?.viewController?.dismiss(animated: true)
                }
                .build()
            let navigationController = createNavigationController(rootViewController: viewController)
            self.viewController?.present(navigationController, animated: true)
        case let .alternativePayment(request):
            let viewController = POAlternativePaymentMethodViewControllerBuilder
                .with(request: request)
                .with { [weak self] _ in
                    self?.viewController?.dismiss(animated: true)
                }
                .build()
            let navigationController = createNavigationController(rootViewController: viewController)
            self.viewController?.present(navigationController, animated: true)
        case let .authorizationtAmount(completion):
            let viewController = AuthorizationAmountBuilder(completion: completion).build()
            self.viewController?.present(viewController, animated: true)
        case let .additionalData(completion):
            let viewController = AlternativePaymentDataBuilder(completion: completion).build()
            self.viewController?.navigationController?.pushViewController(viewController, animated: true)
        }
        return true
    }

    // MARK: - Private Methods

    private func createNavigationController(rootViewController: UIViewController) -> UIViewController {
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
        rootViewController.navigationItem.leftBarButtonItems = [spaceBarButtonItem, cancelBarButtonItem]
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.prefersLargeTitles = false
        return navigationController
    }
}
