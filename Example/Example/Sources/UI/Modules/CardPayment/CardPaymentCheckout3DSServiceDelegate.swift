//
//  CardPaymentCheckout3DSServiceDelegate.swift
//  Example
//
//  Created by Andrii Vysotskyi on 31.01.2024.
//

import UIKit
import ProcessOut
import ProcessOutUI
// import ProcessOutCheckout3DS

// final class CardPaymentCheckout3DSServiceDelegate: POCheckout3DSServiceDelegate {
//
//    func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
//        Task { @MainActor in
//            let session = POWebAuthenticationSession(
//                redirect: redirect, returnUrl: Constants.returnUrl, completion: completion
//            )
//            if await session.start() {
//                return
//            }
//            let failure = POFailure(message: "Unable to process redirect", code: .generic(.mobile))
//            completion(.failure(failure))
//        }
//    }
// }
