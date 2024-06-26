//
//  AlternativePaymentMethodsRouter.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import UIKit
import SafariServices
import ProcessOut
import ProcessOutUI

final class AlternativePaymentMethodsRouter: RouterType {

    weak var viewController: UIViewController?

    func trigger(route: AlternativePaymentMethodsRoute) -> Bool {
        switch route {
        case let .nativeAlternativePayment(route):
            let configuration = PONativeAlternativePaymentConfiguration(
                invoiceId: route.invoiceId,
                gatewayConfigurationId: route.gatewayConfigurationId,
                secondaryAction: .cancel(),
                paymentConfirmation: .init(
                    showProgressIndicatorAfter: 5,
                    secondaryAction: .cancel(disabledFor: 10)
                )
            )
            let viewController = PONativeAlternativePaymentViewController(
                configuration: configuration,
                completion: { [weak self] result in
                    self?.viewController?.dismiss(animated: true) {
                        route.completion(result)
                    }
                }
            )
            viewController.isModalInPresentation = true
            self.viewController?.present(viewController, animated: true)
        case let .alternativePayment(request):
            let session = POWebAuthenticationSession(request: request, returnUrl: Constants.returnUrl) { _ in }
            Task {
                _ = await session.start()
            }
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
