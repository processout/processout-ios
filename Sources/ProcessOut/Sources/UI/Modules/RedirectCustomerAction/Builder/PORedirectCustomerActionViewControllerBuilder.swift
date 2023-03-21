//
//  PORedirectCustomerActionViewControllerBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.11.2022.
//

import UIKit

@_spi(PO)
public final class PORedirectCustomerActionViewControllerBuilder {

    /// - Parameters:
    ///   - url: customer action url.
    ///   - completion: completion to invoke when action handling completes.
    public static func with(context: PO3DSRedirect) -> Self {
        Self(context: context)
    }

    /// Completion to invoke when authorization ends.
    public func with(completion: @escaping (Result<String, POFailure>) -> Void) -> Self {
        self.completion = completion
        return self
    }

    /// Api that will be used by created module to communicate with BE. By default ``ProcessOutApi/shared``
    /// instance is used.
    public func with(api: ProcessOutApiType) -> Self {
        self.api = api
        return self
    }

    /// Return url that was specified when invoice was created.
    public func with(returnUrl: URL) -> Self {
        self.returnUrl = returnUrl
        return self
    }

    /// Returns view controller that caller should encorporate into view controllers hierarchy.
    /// If instance can't be created assertion failure is triggered.
    ///
    /// - NOTE: Caller should dismiss view controller after completion is called.
    public func build() -> UIViewController {
        let api: ProcessOutApiType = self.api ?? ProcessOutApi.shared
        let delegate = RedirectCustomerActionWebViewControllerDelegate(url: context.url) { [completion] result in
            completion?(result)
        }
        var returnUrls = [api.configuration.checkoutBaseUrl]
        if let returnUrl {
            returnUrls.append(returnUrl)
        }
        let viewController = WebViewController(
            eventEmitter: api.eventEmitter,
            delegate: delegate,
            returnUrls: returnUrls,
            version: type(of: api).version,
            timeout: context.timeout,
            logger: api.logger
        )
        return viewController
    }

    // MARK: -

    init(context: PO3DSRedirect) {
        self.context = context
    }

    // MARK: - Private Properties

    private let context: PO3DSRedirect

    private var completion: ((Result<String, POFailure>) -> Void)?
    private var api: ProcessOutApiType?
    private var returnUrl: URL?
}
