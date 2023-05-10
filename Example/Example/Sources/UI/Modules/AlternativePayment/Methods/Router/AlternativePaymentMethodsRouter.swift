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
                secondaryAction: .cancel()
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
            viewController.additionalSafeAreaInsets.top = 12
            self.viewController?.present(viewController, animated: true)
        case let .alternativePayment(request):
            let viewController = POAlternativePaymentMethodViewControllerBuilder
                .with(request: request)
                // swiftlint:disable:next force_unwrapping
                .with(returnUrl: URL(string: "processout-example://return")!)
                .with { [weak self] _ in
                    self?.viewController?.dismiss(animated: true)
                }
                .build()
            self.viewController?.present(viewController, animated: true)
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
}
