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

    public func authenticationRequest(configuration: PO3DS2Configuration) async throws -> PO3DS2AuthenticationRequest {
        let request = PO3DS2AuthenticationRequest(
            deviceData: "",
            sdkAppId: "",
            sdkEphemeralPublicKey: "{}",
            sdkReferenceNumber: "",
            sdkTransactionId: ""
        )
        return request
    }

    @MainActor
    public func handle(challenge: PO3DS2Challenge) async throws -> Bool {
        guard let presentingViewController = PresentingViewControllerProvider.find() else {
            return false
        }
        return await withCheckedContinuation { continuation in
            let alertController = UIAlertController(
                title: String(resource: .Test3DS.title), message: "", preferredStyle: .alert
            )
            let acceptAction = UIAlertAction(title: String(resource: .Test3DS.accept), style: .default) { _ in
                continuation.resume(returning: true)
            }
            alertController.addAction(acceptAction)
            let rejectAction = UIAlertAction(title: String(resource: .Test3DS.reject), style: .default) { _ in
                continuation.resume(returning: false)
            }
            alertController.addAction(rejectAction)
            presentingViewController.present(alertController, animated: true)
        }
    }
}
