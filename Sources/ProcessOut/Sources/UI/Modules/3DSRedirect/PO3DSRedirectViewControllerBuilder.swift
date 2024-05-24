//
//  PO3DSRedirectViewControllerBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.11.2022.
//

import UIKit
import SafariServices

/// Builder that can be used to create view controller that is capable of handling 3DS web redirects.
@available(*, deprecated, message: "Use ProcessOutUI.SFSafariViewController(redirect:returnUrl:safariConfiguration:completion:) instead") // swiftlint:disable:this line_length
public final class PO3DSRedirectViewControllerBuilder {

    /// Creates builder instance with given redirect information.
    /// - Parameters:
    ///   - redirect: redirect information.
    @available(*, deprecated, message: "Use non static method instead.")
    public static func with(redirect: PO3DSRedirect) -> PO3DSRedirectViewControllerBuilder {
        PO3DSRedirectViewControllerBuilder().with(redirect: redirect)
    }

    public typealias Completion = (Result<String, POFailure>) -> Void

    /// Creates builder instance.
    public init() {
        safariConfiguration = SFSafariViewController.Configuration()
    }

    /// Changes redirect information.
    public func with(redirect: PO3DSRedirect) -> Self {
        self.redirect = redirect
        return self
    }

    /// Completion to invoke when authorization ends.
    public func with(completion: @escaping Completion) -> Self {
        self.completion = completion
        return self
    }

    /// Return URL specified when creating invoice.
    public func with(returnUrl: URL) -> Self {
        self.returnUrl = returnUrl
        return self
    }

    /// Allows to inject safari configuration.
    public func with(safariConfiguration: SFSafariViewController.Configuration) -> Self {
        self.safariConfiguration = safariConfiguration
        return self
    }

    /// Returns view controller that caller should incorporate into view controllers hierarchy.
    ///
    /// - Note: Caller should dismiss view controller after completion is called.
    /// - Note: Returned object's delegate shouldn't be modified.
    /// - Warning: Make sure that `completion`, `redirect` and `returnUrl`
    /// are set before calling this method. Otherwise precondition failure is raised.
    public func build() -> SFSafariViewController {
        guard let completion, let returnUrl, let redirect else {
            preconditionFailure("Required parameters are not set.")
        }
        let api: ProcessOut = ProcessOut.shared // swiftlint:disable:this redundant_type_annotation
        let viewController = SFSafariViewController(
            url: redirect.url, configuration: safariConfiguration
        )
        let delegate = ThreeDSRedirectSafariViewModelDelegate(completion: completion)
        let configuration = DefaultSafariViewModelConfiguration(
            returnUrl: returnUrl, timeout: redirect.timeout
        )
        let viewModel = DefaultSafariViewModel(
            configuration: configuration, eventEmitter: api.eventEmitter, logger: api.logger, delegate: delegate
        )
        viewController.delegate = viewModel
        viewController.setViewModel(viewModel)
        viewModel.start()
        return viewController
    }

    // MARK: - Private Properties

    private var redirect: PO3DSRedirect?
    private var returnUrl: URL?
    private var completion: Completion?
    private var safariConfiguration: SFSafariViewController.Configuration
}
