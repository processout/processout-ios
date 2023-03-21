//
//  PO3DSRedirectViewControllerBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.11.2022.
//

import UIKit

public final class PO3DSRedirectViewControllerBuilder {

    /// - Parameters:
    ///   - url: customer action url.
    ///   - completion: completion to invoke when action handling completes.
    public static func with(redirect: PO3DSRedirect) -> Self {
        Self(redirect: redirect)
    }

    /// Completion to invoke when authorization ends.
    public func with(completion: @escaping (Result<String, POFailure>) -> Void) -> Self {
        self.completion = completion
        return self
    }

    /// Returns view controller that caller should encorporate into view controllers hierarchy.
    /// If instance can't be created assertion failure is triggered.
    ///
    /// - NOTE: Caller should dismiss view controller after completion is called.
    public func build() -> UIViewController {
        let api: ProcessOutApiType = ProcessOutApi.shared
        let configuration = WebViewControllerConfiguration(
            returnUrls: [api.configuration.checkoutBaseUrl],
            version: type(of: api).version,
            timeout: redirect.timeout
        )
        let viewController = WebViewController(
            configuration: configuration,
            delegate: WebViewControllerDelegate3DS(url: redirect.url) { [completion] result in
                completion?(result)
            },
            logger: api.logger
        )
        return viewController
    }

    // MARK: - Private Methods

    private init(redirect: PO3DSRedirect) {
        self.redirect = redirect
    }

    // MARK: - Private Properties

    private let redirect: PO3DSRedirect
    private var completion: ((Result<String, POFailure>) -> Void)?
}
