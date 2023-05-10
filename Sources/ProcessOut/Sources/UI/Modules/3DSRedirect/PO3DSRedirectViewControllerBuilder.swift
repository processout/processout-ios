//
//  PO3DSRedirectViewControllerBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.11.2022.
//

import UIKit
import SafariServices

/// Builder that can be used to create view controller that is capable of handling 3DS web redirects.
public final class PO3DSRedirectViewControllerBuilder {

    public typealias Completion = (Result<String, POFailure>) -> Void

    /// Creates builder instance with given redirect information.
    /// - Parameters:
    ///   - redirect: redirect information.
    public static func with(redirect: PO3DSRedirect) -> Self {
        Self(redirect: redirect)
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

    /// Returns view controller that caller should encorporate into view controllers hierarchy.
    /// If instance can't be created precondition failure is triggered.
    ///
    /// - NOTE: Caller should dismiss view controller after completion is called.
    /// - NOTE: Returned object's delegate shouldn't be modified.
    public func build() -> SFSafariViewController {
        guard let completion, let returnUrl else {
            preconditionFailure("Completion must be set.")
        }
        let api: ProcessOutApiType = ProcessOutApi.shared
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

    // MARK: - Private Methods

    private init(redirect: PO3DSRedirect) {
        self.redirect = redirect
        safariConfiguration = SFSafariViewController.Configuration()
    }

    // MARK: - Private Properties

    private let redirect: PO3DSRedirect
    private var returnUrl: URL?
    private var completion: Completion?
    private var safariConfiguration: SFSafariViewController.Configuration
}
