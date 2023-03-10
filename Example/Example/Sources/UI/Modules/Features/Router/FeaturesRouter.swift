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
        let viewController: UIViewController
        switch route {
        case .gatewayConfigurations(let filter):
            viewController = AlternativePaymentMethodsBuilder(filter: filter).build()
        case .cardDetails:
            viewController = CardPaymentBuilder().build()
        }
        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
        return true
    }
}
