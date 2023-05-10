//
//  POAlternativePaymentMethodViewControllerBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.11.2022.
//

import UIKit
import SafariServices

/// Provides an ability to create view controller that could be used to handle Alternative Payment. Call build() to
/// create view controller’s instance.
public final class POAlternativePaymentMethodViewControllerBuilder {

    public typealias Completion = (Result<POAlternativePaymentMethodResponse, POFailure>) -> Void

    /// Creates builder instance with given request.
    public static func with(request: POAlternativePaymentMethodRequest) -> Self {
        Self(request: request)
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

    /// Creates and returns view controller that is capable of handling alternative payment request.
    /// If instance can't be created precondition failure is triggered.
    /// 
    /// - Note: Returned object's delegate shouldn't be modified.
    /// - Note: Returned object's delegate shouldn't be modified.
    /// - Warning: Make sure that `completion` and `returnUrl` are set before calling
    /// this method. Otherwise precondition failure is raised.
    public func build() -> SFSafariViewController {
        guard let completion, let returnUrl else {
            preconditionFailure("Completion and return url must be set.")
        }
        let api: ProcessOutApiType = ProcessOutApi.shared
        let viewController = SFSafariViewController(
            url: api.alternativePaymentMethods.alternativePaymentMethodUrl(request: request),
            configuration: safariConfiguration
        )
        let delegate = AlternativePaymentMethodSafariViewModelDelegate(
            alternativePaymentMethodsService: api.alternativePaymentMethods,
            completion: completion
        )
        let configuration = DefaultSafariViewModelConfiguration(returnUrl: returnUrl, timeout: nil)
        let viewModel = DefaultSafariViewModel(
            configuration: configuration, eventEmitter: api.eventEmitter, logger: api.logger, delegate: delegate
        )
        viewController.delegate = viewModel
        viewController.setViewModel(viewModel)
        viewModel.start()
        return viewController
    }

    // MARK: -

    init(request: POAlternativePaymentMethodRequest) {
        self.request = request
        safariConfiguration = SFSafariViewController.Configuration()
    }

    // MARK: - Private Properties

    private let request: POAlternativePaymentMethodRequest
    private var completion: Completion?
    private var returnUrl: URL?
    private var safariConfiguration: SFSafariViewController.Configuration
}
