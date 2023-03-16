//
//  CardPaymentRouter.swift
//  Example
//
//  Created by Andrii Vysotskyi on 15.03.2023.
//

import UIKit

final class CardPaymentRouter: RouterType {

    weak var viewController: UIViewController?

    func trigger(route: CardPaymentRoute) -> Bool {
        switch route {
        case let .alert(message):
            let viewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            viewController.addAction(
                UIAlertAction(title: Strings.CardPayment.Result.continue, style: .default)
            )
            self.viewController?.present(viewController, animated: true)
        }
        return true
    }
}
