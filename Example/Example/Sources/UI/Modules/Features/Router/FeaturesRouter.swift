//
//  FeaturesRouter.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import SwiftUI
import ProcessOut
@_spi(PO) import ProcessOutUI

final class FeaturesRouter: RouterType {

    weak var viewController: UIViewController?

    func trigger(route: FeaturesRoute) -> Bool {
        switch route {
        case .gatewayConfigurations:
            // todo(andrii-vysotskyi): pass filter
            MainActor.assumeIsolated {
                let viewController = UIHostingController(rootView: AlternativePaymentsView())
                self.viewController?.navigationController?.pushViewController(viewController, animated: true)
            }
        case let .cardTokenization(threeDSService, completion):
            let builder = CardPaymentBuilder(threeDSService: threeDSService) { [weak self] result in
                self?.viewController?.navigationController?.dismiss(animated: true) {
                    completion(result)
                }
            }
            let viewController = builder.build()
            viewController.isModalInPresentation = true
            self.viewController?.navigationController?.present(viewController, animated: true)
        case let .dynamicCheckout(configuration, delegate):
            let viewController = PODynamicCheckoutViewController(
                configuration: configuration,
                delegate: delegate,
                completion: { [weak self] _ in
                    self?.viewController?.navigationController?.dismiss(animated: true)
                }
            )
            viewController.isModalInPresentation = true
            self.viewController?.navigationController?.present(viewController, animated: true)
        case .alert(let message):
            let viewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            viewController.addAction(
                UIAlertAction(title: String(localized: .Features.continue), style: .default)
            )
            self.viewController?.present(viewController, animated: true)
        case .configuration:
            let viewController = UIHostingController(rootView: ConfigurationView())
            self.viewController?.present(viewController, animated: true)
        }
        return true
    }
}
