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
        case let .nativeAlternativePayment(route):
            let configuration = PONativeAlternativePaymentMethodConfiguration(
                secondaryAction: .cancel(),
                paymentConfirmationSecondaryAction: .cancel(disabledFor: 10)
            )
            let viewController = PONativeAlternativePaymentMethodViewControllerBuilder
                .with(invoiceId: route.invoiceId, gatewayConfigurationId: route.gatewayConfigurationId)
                .with { [weak self] result in
                    self?.viewController?.dismiss(animated: true) {
                        route.completion(result)
                    }
                }
                .with(configuration: configuration)
                .build()
            self.viewController?.present(viewController, animated: true)
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
        case let .alert(message):
            let viewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            viewController.addAction(
                UIAlertAction(title: Strings.AlternativePaymentMethods.Result.continue, style: .default)
            )
            self.viewController?.present(viewController, animated: true)
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
