//
//  AlternativePaymentDataRouter.swift
//  Example
//
//  Created by Andrii Vysotskyi on 25.01.2023.
//

import UIKit

final class AlternativePaymentDataRouter: RouterType {

    weak var viewController: UIViewController?

    func trigger(route: AlternativePaymentDataRoute) -> Bool {
        switch route {
        case .close:
            self.viewController?.navigationController?.popViewController(animated: true)
        case let .additionalData(completion):
            let viewController = AlternativePaymentDataEntryBuilder(completion: completion).build()
            self.viewController?.navigationController?.present(viewController, animated: true)
        }
        return true
    }
}
