//
//  TestThreeDSHandler.swift
//  Example
//
//  Created by Andrii Vysotskyi on 15.03.2023.
//

import UIKit
@_spi(PO) import ProcessOut

final class TestThreeDSHandler: POThreeDSHandlerType {

    /// View controller to use for presentations.
    unowned var viewController: UIViewController! // swiftlint:disable:this implicitly_unwrapped_optional

    // MARK: - POThreeDSHandlerType

    func fingerprint(
        data: PODirectoryServerData, completion: @escaping (Result<PODeviceFingerprint, POFailure>) -> Void
    ) {
        let deviceFingerprint = PODeviceFingerprint(
            deviceInformation: "",
            applicationId: "",
            sdkEphemeralPublicKey: nil,
            sdkReferenceNumber: "",
            sdkTransactionId: ""
        )
        completion(.success(deviceFingerprint))
    }

    func challenge(
        challenge: POAuthentificationChallengeData, completion: @escaping (Result<Bool, POFailure>) -> Void
    ) {
        let alertController = UIAlertController(
            title: "Do you want to accept the 3DS2 challenge", message: "", preferredStyle: .alert
        )
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { _ in
            completion(.success(true))
        }
        alertController.addAction(acceptAction)
        let rejectAction = UIAlertAction(title: "Reject", style: .default) { _ in
            completion(.success(false))
        }
        alertController.addAction(rejectAction)
        self.viewController.present(alertController, animated: true)
    }

    func redirect(context: PORedirectCustomerActionContext, completion: @escaping (Result<String, POFailure>) -> Void) {
        let viewController = PORedirectCustomerActionViewControllerBuilder
            .with(context: context)
            .with { [weak self] result in
                self?.viewController.dismiss(animated: true) {
                    completion(result)
                }
            }
            .build()
        self.viewController.present(viewController, animated: true)
    }
}
