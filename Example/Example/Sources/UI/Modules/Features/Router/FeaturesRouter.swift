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
            viewController?.navigationController?.pushViewController(
                AlternativePaymentMethodsBuilder(filter: filter).build(), animated: true
            )
        case .cardDetails:
            return false
        }
        return true
    }
}
