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
public final class POTest3DSService: PO3DSService {

    /// Creates service instance.
    @_disfavoredOverload
    public init(returnUrl: URL) {
        self.returnUrl = returnUrl
    }

    /// View controller to use for presentations.
    @MainActor
    public unowned var viewController: UIViewController! // swiftlint:disable:this implicitly_unwrapped_optional

    // MARK: - PO3DSService

    public func authenticationRequest(
        configuration: PO3DS2Configuration,
        completion: @escaping @Sendable (Result<PO3DS2AuthenticationRequest, POFailure>) -> Void
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

    public func handle(challenge: PO3DS2Challenge, completion: @escaping @Sendable (Result<Bool, POFailure>) -> Void) {
        MainActor.assumeIsolated {
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
            viewController.present(alertController, animated: true)
        }
    }

    public func handle(redirect: PO3DSRedirect, completion: @escaping @Sendable (Result<String, POFailure>) -> Void) {
        MainActor.assumeIsolated {
            let viewController = PO3DSRedirectViewControllerBuilder()
                .with(redirect: redirect)
                .with(returnUrl: returnUrl)
                .with { [weak self] result in
                    self?.viewController.presentedViewController?.dismiss(animated: true) {
                        completion(result)
                    }
                }
                .build()
            self.viewController.present(viewController, animated: true)
        }
    }

    // MARK: - Private Properties

    private let returnUrl: URL
}
