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

    public nonisolated init() {
        // Ignored
    }

    public func authenticationRequestParameters(
        configuration: PO3DS2Configuration
    ) async throws -> PO3DS2AuthenticationRequestParameters {
        PO3DS2AuthenticationRequestParameters(
            deviceData: "",
            sdkAppId: "",
            sdkEphemeralPublicKey: "{}",
            sdkReferenceNumber: "",
            sdkTransactionId: ""
        )
    }

    @MainActor
    public func performChallenge(with parameters: PO3DS2ChallengeParameters) async throws -> PO3DS2ChallengeResult {
        guard let presentingViewController = PresentingViewControllerProvider.find() else {
            throw POFailure(code: .generic(.mobile))
        }
        return await withCheckedContinuation { continuation in
            let alertController = UIAlertController(
                title: String(resource: .Test3DS.title), message: "", preferredStyle: .alert
            )
            let acceptAction = UIAlertAction(title: String(resource: .Test3DS.accept), style: .default) { _ in
                continuation.resume(returning: PO3DS2ChallengeResult(transactionStatus: "Y"))
            }
            alertController.addAction(acceptAction)
            let rejectAction = UIAlertAction(title: String(resource: .Test3DS.reject), style: .default) { _ in
                continuation.resume(returning: PO3DS2ChallengeResult(transactionStatus: "N"))
            }
            alertController.addAction(rejectAction)
            presentingViewController.present(alertController, animated: true)
        }
    }
}
