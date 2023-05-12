//
//  POTest3DSService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.04.2023.
//

import UIKit

/// Service that emulates the normal 3DS authentication flow but does not actually make any calls to a real Access
/// Control Server (ACS). Should be used only for testing purposes in sandbox environment.
public final class POTest3DSService: PO3DSService {

    /// Creates service instance.
    public init() {
        // NOP
    }

    /// View controller to use for presentations.
    public unowned var viewController: UIViewController! // swiftlint:disable:this implicitly_unwrapped_optional

    // MARK: - PO3DSService

    public func authenticationRequest(
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

    public func handle(challenge: PO3DS2Challenge, completion: @escaping (Result<Bool, POFailure>) -> Void) {
        let alertController = UIAlertController(
            title: Strings.Test3DS.Challenge.title, message: "", preferredStyle: .alert
        )
        let acceptAction = UIAlertAction(title: Strings.Test3DS.Challenge.accept, style: .default) { _ in
            completion(.success(true))
        }
        alertController.addAction(acceptAction)
        let rejectAction = UIAlertAction(title: Strings.Test3DS.Challenge.reject, style: .default) { _ in
            completion(.success(false))
        }
        alertController.addAction(rejectAction)
        viewController.present(alertController, animated: true)
    }

    public func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
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
