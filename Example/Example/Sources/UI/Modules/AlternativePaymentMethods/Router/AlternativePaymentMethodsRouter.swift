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
                .build()
            self.viewController?.present(viewController, animated: true)
        case let .alternativePayment(request):
            let viewController = POAlternativePaymentMethodViewControllerBuilder
                .with(request: request)
                .with { [weak viewController] _ in
                    viewController?.presentedViewController?.dismiss(animated: true)
                }
                .build()
            viewController.isModalInPresentation = true
            self.viewController?.present(viewController, animated: true)
        }
        return true
    }
}
