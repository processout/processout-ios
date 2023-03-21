//
//  CardPaymentTestThreeDSHandler.swift
//  Example
//
//  Created by Andrii Vysotskyi on 15.03.2023.
//

import UIKit
@_spi(PO) import ProcessOut

final class CardPaymentTestThreeDSHandler: PO3DSServiceType {

    /// View controller to use for presentations.
    unowned var viewController: UIViewController! // swiftlint:disable:this implicitly_unwrapped_optional

    // MARK: - PO3DSServiceType

    func authenticationRequest(
        configuration: PO3DS2Configuration,
        completion: @escaping (Result<PO3DS2AuthenticationRequest, POFailure>) -> Void
    ) {
        let request = PO3DS2AuthenticationRequest(
            deviceData: "",
            sdkAppId: "",
            sdkEphemeralPublicKey: "{}",
            sdkReferenceNumber: "",
            sdkTransactionId: ""
        )
        completion(.success(request))
    }

    func handle(challenge: PO3DS2Challenge, completion: @escaping (Result<Bool, POFailure>) -> Void) {
        let alertController = UIAlertController(
            title: Strings.CardPayment.Challenge.title, message: "", preferredStyle: .alert
        )
        let acceptAction = UIAlertAction(title: Strings.CardPayment.Challenge.accept, style: .default) { _ in
            completion(.success(true))
        }
        alertController.addAction(acceptAction)
        let rejectAction = UIAlertAction(title: Strings.CardPayment.Challenge.reject, style: .default) { _ in
            completion(.success(false))
        }
        alertController.addAction(rejectAction)
        self.viewController.present(alertController, animated: true)
    }

    func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
        let viewController = PO3DSRedirectViewControllerBuilder
            .with(redirect: redirect)
            .with { [weak self] result in
                self?.viewController.dismiss(animated: true) {
                    completion(result)
                }
            }
            .build()
        self.viewController.present(viewController, animated: true)
    }
}
