//
//  CardPaymentCheckout3DSServiceDelegate.swift
//  Example
//
//  Created by Andrii Vysotskyi on 31.01.2024.
//

import UIKit
import ProcessOut
import ProcessOutUI
import ProcessOutCheckout3DS

final class CardPaymentCheckout3DSServiceDelegate: POCheckout3DSServiceDelegate {

    func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
        let controller = PO3DSRedirectController(redirect: redirect, returnUrl: Constants.returnUrl)
        controller.completion = { [weak controller] result in
            controller?.dismiss {
                completion(result)
            }
        }
        controller.present()
    }
}
