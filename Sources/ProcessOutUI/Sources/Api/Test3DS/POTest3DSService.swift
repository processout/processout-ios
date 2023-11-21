//
//  POTest3DSService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.04.2023.
//

import UIKit
import ProcessOut

/// Service that emulates the normal 3DS authentication flow but does not actually make any calls to a real Access
/// Control Server (ACS). Should be used only for testing purposes in sandbox environment.
public final class POTest3DSService: PO3DSService {

    /// Creates service instance.
    public init(returnUrl: URL) {
        self.returnUrl = returnUrl
    }

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
        guard let presentingViewController = PresentingViewControllerProvider.find() else {
            completion(.success(false))
            return
        }
        let alertController = UIAlertController(
            title: String(resource: .Test3DS.title), message: "", preferredStyle: .alert
        )
        let acceptAction = UIAlertAction(title: String(resource: .Test3DS.accept), style: .default) { _ in
            completion(.success(true))
        }
        alertController.addAction(acceptAction)
        let rejectAction = UIAlertAction(title: String(resource: .Test3DS.reject), style: .default) { _ in
            completion(.success(false))
        }
        alertController.addAction(rejectAction)
        presentingViewController.present(alertController, animated: true)
    }

    public func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
        let controller = PO3DSRedirectController(redirect: redirect, returnUrl: returnUrl)
        controller.completion = { [weak controller] result in
            controller?.dismiss { completion(result) }
        }
        controller.present()
    }

    // MARK: - Private Properties

    private let returnUrl: URL
}
