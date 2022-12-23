//
//  POCustomerActionViewControllerBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.11.2022.
//

import UIKit

@_spi(PO)
public final class POCustomerActionViewControllerBuilder {

    public typealias Completion = (Result<String, POFailure>) -> Void

    /// - Parameters:
    ///   - url: customer action url.
    ///   - completion: completion to invoke when action handling completes.
    public static func with(url: URL) -> Self {
        Self(url: url)
    }

    /// Completion to invoke when authorization ends.
    public func with(completion: @escaping Completion) -> Self {
        self.completion = completion
        return self
    }

    /// Api that will be used by created module to communicate with BE. By default ``ProcessOutApi/shared``
    /// instance is used.
    public func with(api: ProcessOutApiType) -> Self {
        self.api = api
        return self
    }

    /// Returns view controller that caller should encorporate into view controllers hierarchy.
    /// If instance can't be created assertion failure is triggered.
    ///
    /// - NOTE: Caller should dismiss view controller after completion is called.
    public func build() -> UIViewController {
        let api: ProcessOutApiType = self.api ?? ProcessOutApi.shared
        let viewController = WebViewController(
            delegate: CustomerActionWebViewControllerDelegate(url: url),
            baseReturnUrl: api.configuration.checkoutBaseUrl,
            version: type(of: api).version,
            completion: completion
        )
        return viewController
    }

    // MARK: -

    init(url: URL) {
        self.url = url
    }

    // MARK: - Private Properties

    private let url: URL
    private var completion: Completion?
    private var api: ProcessOutApiType?
}
