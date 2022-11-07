//
//  POCustomerActionViewControllerBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.11.2022.
//

import UIKit

public final class POCustomerActionViewControllerBuilder {

    /// - Parameters:
    ///   - url: customer action url.
    ///   - completion: completion to invoke when action handling completes.
    public static func with(url: URL, completion: @escaping (Result<String, Error>) -> Void) -> Self {
        Self(url: url, completion: completion)
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
        return CustomerActionViewController(
            checkoutBaseUrl: api.configuration.checkoutBaseUrl,
            customerActionUrl: url,
            version: type(of: api).version,
            completion: completion
        )
    }

    // MARK: -

    init(url: URL, completion: @escaping (Result<String, Error>) -> Void) {
        self.url = url
        self.completion = completion
    }

    // MARK: - Private Properties

    private let url: URL
    private let completion: (Result<String, Error>) -> Void

    private var api: ProcessOutApiType?
}
