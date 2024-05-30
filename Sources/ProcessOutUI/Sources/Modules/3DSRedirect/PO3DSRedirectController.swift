//
//  PO3DSRedirectController.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.11.2023.
//

import Foundation
import SafariServices
import ProcessOut

/// An object that presents a screen that allows to handle 3DS redirect.
///
/// - Important: The PO3DSRedirectController class performs the same role as the SFSafariViewController
/// class initialized with 3DSRedirect, but it does not depend on the UIKit framework. This means that
/// the controller can be used in places where a view controller cannot (for example, in SwiftUI applications).
@available(*, deprecated, message: "Use POWebAuthenticationSession instead.")
public final class PO3DSRedirectController {

    /// - Parameters:
    ///   - redirect: redirect to handle.
    ///   - returnUrl: Return URL specified when creating invoice or customer token.
    ///   - safariConfiguration: The configuration for the new view controller.
    public init(
        redirect: PO3DSRedirect,
        returnUrl: URL,
        safariConfiguration: SFSafariViewController.Configuration = SFSafariViewController.Configuration()
    ) {
        self.redirect = redirect
        self.returnUrl = returnUrl
        self.safariConfiguration = safariConfiguration
    }

    /// Presents the Redirect UI modally over your app. You are responsible for dismissal.
    ///
    /// - Parameters:
    ///   - completion: A block that is called after the screen is presented.
    ///   - success: A Boolean value that indicates whether the screen was successfully presented.
    ///
    /// - NOTE: Redirect controller is retained for the duration of presentation.
    public func present(completion: ((_ success: Bool) -> Void)? = nil) {
        guard safariViewController == nil else {
            preconditionFailure("Controller is already presented.")
        }
        if let presentingViewController = PresentingViewControllerProvider.find() {
            let safariViewController = SFSafariViewController(
                redirect: redirect,
                returnUrl: returnUrl,
                safariConfiguration: safariConfiguration,
                completion: self.completion ?? { _ in }
            )
            safariViewController.preferredBarTintColor = preferredBarTintColor
            safariViewController.preferredControlTintColor = preferredControlTintColor
            safariViewController.dismissButtonStyle = .cancel
            presentingViewController.present(safariViewController, animated: true) {
                completion?(true)
            }
            objc_setAssociatedObject(
                safariViewController, &AssociatedKeys.redirectController, self, .OBJC_ASSOCIATION_RETAIN
            )
            self.safariViewController = safariViewController
        } else {
            completion?(false)
            let failure = POFailure(message: "Unable to present redirect UI.", code: .generic(.mobile))
            self.completion?(.failure(failure))
        }
    }

    /// Dismisses the Redirect UI.
    public func dismiss(completion: (() -> Void)? = nil) {
        // todo(andrii-vysotskyi): automatically dismiss controller so behavior
        // matches `POAlternativePaymentMethodController`.
        if let safariViewController, safariViewController.presentingViewController != nil {
            self.safariViewController = nil
            safariViewController.dismiss(animated: true, completion: completion)
        } else {
            completion?()
        }
    }

    /// Completion to invoke when redirect handling ends.
    public var completion: ((Result<String, POFailure>) -> Void)?

    /// The preferred color to tint the background of the navigation bar and toolbar.
    public var preferredBarTintColor: UIColor?

    /// The preferred color to tint the control buttons on the navigation bar and toolbar.
    public var preferredControlTintColor: UIColor?

    // MARK: - Private Nested Types

    private enum AssociatedKeys {
        static var redirectController: UInt8 = 0
    }

    // MARK: - Private Properties

    private let redirect: PO3DSRedirect
    private let returnUrl: URL
    private let safariConfiguration: SFSafariViewController.Configuration

    private weak var safariViewController: SFSafariViewController?
}
