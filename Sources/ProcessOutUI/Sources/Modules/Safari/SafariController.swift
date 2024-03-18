//
//  SafariController.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.03.2024.
//

import SafariServices

/// Wrapper for `SFSafariViewController` that can be presented when UIKit context is not available.
final class SafariController {

    var createViewController: (() -> SFSafariViewController)! // swiftlint:disable:this implicitly_unwrapped_optional

    /// Presents the view controller modally over your app. You are responsible for dismissal.
    ///
    /// - Parameters:
    ///   - completion: A block that is called after the screen is presented.
    ///   - success: A Boolean value that indicates whether the screen was successfully presented.
    ///
    /// - NOTE: View controller is retained for the duration of presentation.
    func present(completion: ((_ success: Bool) -> Void)? = nil) {
        guard safariViewController.presentingViewController == nil else {
            preconditionFailure("Controller is already presented.")
        }
        if let presentingViewController = PresentingViewControllerProvider.find() {
            presentingViewController.present(safariViewController, animated: true) {
                completion?(true)
            }
            objc_setAssociatedObject(
                safariViewController, &AssociatedKeys.viewController, self, .OBJC_ASSOCIATION_RETAIN
            )
        } else {
            completion?(false)
        }
    }

    /// Dismisses the view controller.
    func dismiss(completion: (() -> Void)? = nil) {
        if safariViewController.presentingViewController != nil {
            safariViewController.dismiss(animated: true, completion: completion)
        } else {
            completion?()
        }
        // Break retain cycle to allow de-initialization of self.
        objc_removeAssociatedObjects(safariViewController)
    }

    /// The preferred color to tint the background of the navigation bar and toolbar.
    var preferredBarTintColor: UIColor?

    /// The preferred color to tint the control buttons on the navigation bar and toolbar.
    var preferredControlTintColor: UIColor?

    // MARK: - Private Nested Types

    private enum AssociatedKeys {
        static var viewController: UInt8 = 0
    }

    // MARK: - Private Properties

    private lazy var safariViewController: SFSafariViewController = {
        let viewController = createViewController()
        viewController.preferredBarTintColor = preferredBarTintColor
        viewController.preferredControlTintColor = preferredControlTintColor
        viewController.dismissButtonStyle = .cancel
        return viewController
    }()
}
