//
//  FeaturesRouter.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import UIKit
import ProcessOut

final class FeaturesRouter: RouterType {

    weak var viewController: UIViewController?

    func trigger(route: FeaturesRoute) -> Bool {
        switch route {
        case .gatewayConfigurations(let filter):
            let viewController = AlternativePaymentMethodsBuilder(filter: filter).build()
            self.viewController?.navigationController?.pushViewController(viewController, animated: true)
        case .cardTokenization(let completion):
            let builder = CardPaymentBuilder { [weak self] result in
                self?.viewController?.navigationController?.dismiss(animated: true) {
                    completion(result)
                }
            }
            let viewController = builder.build()
            viewController.isModalInPresentation = true
            self.viewController?.navigationController?.present(viewController, animated: true)
        case .alert(let message):
            let viewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            viewController.addAction(
                UIAlertAction(title: Strings.Features.continue, style: .default)
            )
            self.viewController?.present(viewController, animated: true)
        }
        return true
    }
}
