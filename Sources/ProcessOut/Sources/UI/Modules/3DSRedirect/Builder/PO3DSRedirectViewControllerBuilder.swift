//
//  PO3DSRedirectViewControllerBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.11.2022.
//

import UIKit

@_spi(PO)
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
        let api: ProcessOutApiType = ProcessOutApi.shared
        var returnUrls = [api.configuration.checkoutBaseUrl]
        if let returnUrl {
            returnUrls.append(returnUrl)
        }
        let viewController = WebViewController(
            eventEmitter: api.eventEmitter,
            delegate: WebViewControllerDelegate3DS(url: redirect.url) { [completion] result in
                completion?(result)
            },
            returnUrls: returnUrls,
            version: type(of: api).version,
            timeout: redirect.timeout,
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
    private var returnUrl: URL?
}
