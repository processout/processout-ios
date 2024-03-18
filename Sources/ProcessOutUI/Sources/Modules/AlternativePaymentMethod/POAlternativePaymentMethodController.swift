//
//  POAlternativePaymentMethodController.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.03.2024.
//

import Foundation
import SafariServices
import ProcessOut

/// An object that presents a screen that can handle Alternative Payments.
///
/// - Important: The POAlternativePaymentMethodController class performs the same role as
/// the SFSafariViewController class initialized with POAlternativePaymentMethodRequest, but it
/// does not depend on the UIKit framework.
@MainActor
@_spi(PO)
public final class POAlternativePaymentMethodController {

    public typealias Completion = (Result<POAlternativePaymentMethodResponse, POFailure>) -> Void

    /// Creates view controller that is capable of handling Alternative Payment.
    ///
    /// - Note: Caller should dismiss view after completion is called.
    ///
    /// - Parameters:
    ///   - returnUrl: Return URL specified when creating invoice.
    ///   - safariConfiguration: The configuration for the new view controller.
    ///   - completion: Completion to invoke when APM flow completes.
    public convenience init(
        request: POAlternativePaymentMethodRequest, returnUrl: URL, completion: @escaping Completion
    ) {
        let url = ProcessOut.shared.alternativePaymentMethods.alternativePaymentMethodUrl(request: request)
        self.init(url: url, returnUrl: returnUrl, completion: completion)
    }

    /// Creates view controller that is capable of handling Alternative Payment.
    ///
    /// - Parameters:
    ///   - url: initial URL instead of **request**. Implementation does not validate
    ///   whether given value is valid to actually start APM flow.
    ///   - returnUrl: Return URL specified when creating invoice.
    ///   - safariConfiguration: The configuration for the new view controller.
    ///   - completion: Completion to invoke when APM flow completes.
    public init(url: URL, returnUrl: URL, completion: @escaping Completion) {
        self.url = url
        self.returnUrl = returnUrl
        self.completion = completion
        didAttemptPresentation = false
    }

    // MARK: - Starting and Stopping a Controller

    /// Starts an alternative payment.
    ///
    /// - Returns: A Boolean value that indicates whether the screen was successfully presented.
    /// - NOTE: Controller is retained for the duration of presentation.
    public func present() async -> Bool {
        guard !didAttemptPresentation else {
            assertionFailure("Controller must be presented only once.")
            return false
        }
        didAttemptPresentation = true
        guard let presentingViewController = PresentingViewControllerProvider.find() else {
            let failure = POFailure(message: "Unable to present UI.", code: .generic(.mobile))
            completion(.failure(failure))
            return false
        }
        objc_setAssociatedObject(viewController, &AssociatedKeys.viewController, self, .OBJC_ASSOCIATION_RETAIN)
        await withCheckedContinuation { continuation in
            presentingViewController.present(viewController, animated: true, completion: continuation.resume)
        }
        return true
    }

    /// Cancels an alternative payment.
    ///
    /// If the controller has already presented a view with the APM webpage, calling this method
    /// dismisses that view. Calling `dismiss()` on an already canceled controller has no effect.
    public func dismiss() async {
        guard viewController.presentingViewController != nil else {
            return
        }
        // Break retain cycle to allow de-initialization of self.
        objc_removeAssociatedObjects(viewController)
        await withCheckedContinuation { continuation in
            viewController.dismiss(animated: true, completion: continuation.resume)
        }
    }

    // MARK: -

    /// Presented view controller configuration.
    public var safariConfiguration = SFSafariViewController.Configuration()

    /// The preferred color to tint the background of the navigation bar and toolbar.
    public var preferredBarTintColor: UIColor?

    /// The preferred color to tint the control buttons on the navigation bar and toolbar.
    public var preferredControlTintColor: UIColor?

    // MARK: - Private Nested Types

    private enum AssociatedKeys {
        static var viewController: UInt8 = 0
    }

    // MARK: - Private Properties

    private let url, returnUrl: URL
    private let completion: Completion

    private lazy var viewController: SFSafariViewController = {
        let viewController = SFSafariViewController(
            alternativePaymentMethodUrl: url,
            returnUrl: returnUrl,
            safariConfiguration: safariConfiguration,
            completion: { [weak self] result in
                self?.complete(with: result)
            }
        )
        viewController.preferredBarTintColor = preferredBarTintColor
        viewController.preferredControlTintColor = preferredControlTintColor
        viewController.dismissButtonStyle = .cancel
        return viewController
    }()

    private var didAttemptPresentation: Bool

    // MARK: - Private Methods

    private func complete(with result: Result<POAlternativePaymentMethodResponse, POFailure>) {
        Task {
            await self.dismiss()
            self.completion(result)
        }
    }
}
