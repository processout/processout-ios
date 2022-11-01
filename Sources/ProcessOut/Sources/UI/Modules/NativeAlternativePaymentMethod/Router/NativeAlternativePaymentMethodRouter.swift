//
//  NativeAlternativePaymentMethodRouter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.10.2022.
//

import UIKit

final class NativeAlternativePaymentMethodRouter: RouterType {

    weak var viewController: UIViewController?

    func trigger(route: NativeAlternativePaymentMethodRoute) -> Bool {
        guard let viewController else {
            return false
        }
        switch route {
        case let .close(completion):
            viewController.dismiss(animated: true, completion: completion)
        }
        return true
    }
}
