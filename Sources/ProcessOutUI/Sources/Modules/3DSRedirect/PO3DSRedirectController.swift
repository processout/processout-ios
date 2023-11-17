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
public final class PO3DSRedirectController {

    /// - Parameters:
    ///   - redirect: redirect to handle.
    ///   - returnUrl: Return URL specified when creating invoice or customer token.
    ///   - safariConfiguration: The configuration for the new view controller.
    ///   - completion: Completion to invoke when redirect handling ends.
    public init(
        redirect: PO3DSRedirect,
        returnUrl: URL,
        safariConfiguration: SFSafariViewController.Configuration = SFSafariViewController.Configuration(),
        completion: @escaping (Result<String, POFailure>) -> Void
    ) {
        safariViewController = .init(
            redirect: redirect, returnUrl: returnUrl, safariConfiguration: safariConfiguration, completion: completion
        )
    }

    /// Presents the Redirect UI modally over your app. You are responsible for dismissal
    ///
    /// - Parameters:
    ///   - completion: A block that is called after the screen is presented.
    ///   - success: A Boolean value that indicates whether the payment sheet was successfully presented. true
    /// if the payment sheet was presented successfully; otherwise, false.
    public func present(completion: @escaping (_ success: Bool) -> Void) {
        guard safariViewController.presentingViewController == nil else {
            assertionFailure("Attempted to present already visible controller.")
            return
        }
        let rootViewController = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .windows
            .first(where: \.isKeyWindow)?
            .rootViewController
        var presentingViewController = rootViewController
        while let presented = presentingViewController?.presentedViewController {
            presentingViewController = presented
        }
        guard let presentingViewController else {
            completion(false)
            return
        }
        presentingViewController.present(safariViewController, animated: true) { completion(true) }
    }

    /// Dismisses the Redirect UI. Call this when you receive the completion or otherwise wish a dismissal to occur.
    public func dismiss(completion: (() -> Void)? = nil) {
        safariViewController.presentingViewController?.dismiss(animated: true, completion: completion)
    }

    /// The preferred color to tint the background of the navigation bar and toolbar.
    public var preferredBarTintColor: UIColor? {
        get { safariViewController.preferredBarTintColor }
        set { safariViewController.preferredBarTintColor = newValue }
    }

    /// The preferred color to tint the control buttons on the navigation bar and toolbar.
    public var preferredControlTintColor: UIColor? {
        get { safariViewController.preferredControlTintColor }
        set { safariViewController.preferredControlTintColor = newValue }
    }

    /// The style of dismiss button to use in the navigation bar to close SFSafariViewController.
    var dismissButtonStyle: SFSafariViewController.DismissButtonStyle {
        get { safariViewController.dismissButtonStyle }
        set { safariViewController.dismissButtonStyle = newValue }
    }

    // MARK: - Private Properties

    private let safariViewController: SFSafariViewController
}
