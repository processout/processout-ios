//
//  CardPayment3DSServiceDelegate.swift
//  Example
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

import UIKit
import ProcessOut
import ProcessOutCheckout3DS

final class CardPayment3DSServiceDelegate: POCheckout3DSServiceDelegate {

    /// View controller to use for presentations.
    unowned var viewController: UIViewController! // swiftlint:disable:this implicitly_unwrapped_optional

    func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
        let viewController = PO3DSRedirectViewControllerBuilder()
            .with(redirect: redirect)
            .with(returnUrl: Constants.returnUrl)
            .with { [weak self] result in
                self?.viewController.dismiss(animated: true) {
                    completion(result)
                }
            }
            .build()
        self.viewController.present(viewController, animated: true)
    }
}
