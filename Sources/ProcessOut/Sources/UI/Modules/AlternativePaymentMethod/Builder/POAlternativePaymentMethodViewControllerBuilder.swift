//
//  POAlternativePaymentMethodViewControllerBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.11.2022.
//

import UIKit

public final class POAlternativePaymentMethodViewControllerBuilder {

    public static func with(request: POAlternativePaymentMethodRequest) -> Self {
        Self(request: request)
    }

    /// Completion to invoke when authorization ends.
    public func with(
        completion: @escaping (Result<POAlternativePaymentMethodResponse, POFailure>) -> Void
    ) -> Self {
        self.completion = completion
        return self
    }

    /// Return url that was specified when invoice was created.
    public func with(returnUrl: URL) -> Self {
        self.returnUrl = returnUrl
        return self
    }

    /// Creates and returns view controller that is capable of handling alternative payment request.
    public func build() -> UIViewController {
        let api: ProcessOutApiType = ProcessOutApi.shared
        let delegate = WebViewControllerDelegateAlternativePaymentMethod(
            alternativePaymentMethodsService: api.alternativePaymentMethods,
            request: request,
            completion: { [completion] result in
                completion?(result)
            }
        )
        let configuration = WebViewControllerConfiguration(
            returnUrls: [api.configuration.checkoutBaseUrl, returnUrl].compactMap { $0 },
            version: type(of: api).version,
            timeout: nil
        )
        let viewController = WebViewController(
            configuration: configuration,
            delegate: delegate,
            eventEmitter: api.eventEmitter,
            logger: api.logger
        )
        return viewController
    }

    // MARK: -

    init(request: POAlternativePaymentMethodRequest) {
        self.request = request
    }

    // MARK: - Private Properties

    private let request: POAlternativePaymentMethodRequest
    private var completion: ((Result<POAlternativePaymentMethodResponse, POFailure>) -> Void)?
    private var returnUrl: URL?
}
