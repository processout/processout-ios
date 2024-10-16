//
//  POTest3DSService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.04.2023.
//

import UIKit

/// Service that emulates the normal 3DS authentication flow but does not actually make any calls to a real Access
/// Control Server (ACS). Should be used only for testing purposes in sandbox environment.
@available(*, deprecated, message: "Use ProcessOutUI.POTest3DSService instead.")
@MainActor
@preconcurrency
public final class POTest3DSService: PO3DS2Service {

    /// Creates service instance.
    @_disfavoredOverload
    @available(*, deprecated, message: "Use init that doesn't require arguments.")
    public nonisolated init(returnUrl: URL) {
        // Ignored
    }

    nonisolated init() {
        // Ignored
    }

    /// View controller to use for presentations.
    public unowned var viewController: UIViewController! // swiftlint:disable:this implicitly_unwrapped_optional

    // MARK: - PO3DSS2ervice

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

    public func performChallenge(with parameters: PO3DS2ChallengeParameters) async throws -> PO3DS2ChallengeResult {
        await withCheckedContinuation { continuation in
            let alertController = UIAlertController(
                title: String(resource: .Test3DS.title), message: "", preferredStyle: .alert
            )
            let acceptAction = UIAlertAction(title: String(resource: .Test3DS.accept), style: .default) { _ in
                continuation.resume(returning: PO3DS2ChallengeResult(transactionStatus: true))
            }
            alertController.addAction(acceptAction)
            let rejectAction = UIAlertAction(title: String(resource: .Test3DS.reject), style: .default) { _ in
                continuation.resume(returning: PO3DS2ChallengeResult(transactionStatus: false))
            }
            alertController.addAction(rejectAction)
            viewController.present(alertController, animated: true)
        }
    }
}
