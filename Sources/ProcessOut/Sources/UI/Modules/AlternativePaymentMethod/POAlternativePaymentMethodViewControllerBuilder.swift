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

    /// Creates builder instance with given request.
    @available(*, deprecated, message: "Use non static method instead.")
    public static func with(
        request: POAlternativePaymentMethodRequest
    ) -> POAlternativePaymentMethodViewControllerBuilder {
        POAlternativePaymentMethodViewControllerBuilder().with(request: request)
    }

    public typealias Completion = (Result<POAlternativePaymentMethodResponse, POFailure>) -> Void

    /// Creates builder instance.
    public init() {
        safariConfiguration = SFSafariViewController.Configuration()
    }

    /// Changes request.
    public func with(request: POAlternativePaymentMethodRequest) -> Self {
        self.request = request
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

    /// Creates and returns view controller that is capable of handling alternative payment request.
    /// If instance can't be created precondition failure is triggered.
    /// 
    /// - Note: Caller should dismiss view controller after completion is called.
    /// - Note: Returned object's delegate shouldn't be modified.
    /// - Warning: Make sure that `completion`, `request` and `returnUrl` are set
    /// before calling this method. Otherwise precondition failure is raised.
    public func build() -> SFSafariViewController {
        guard let completion, let returnUrl, let request else {
            preconditionFailure("Completion, return url and request must be set.")
        }
        let api: ProcessOut = ProcessOut.shared // swiftlint:disable:this redundant_type_annotation
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

    // MARK: - Private Properties

    private var request: POAlternativePaymentMethodRequest?
    private var completion: Completion?
    private var returnUrl: URL?
    private var safariConfiguration: SFSafariViewController.Configuration
}
