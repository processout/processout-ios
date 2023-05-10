//
//  POAlternativePaymentMethodViewControllerBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.11.2022.
//

import UIKit

/// Provides an ability to create view controller that could be used to handle Alternative Payment. Call build() to
/// create view controller’s instance.
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

    /// Creates and returns view controller that is capable of handling alternative payment request.
    public func build() -> UIViewController {
        let api: ProcessOutApiType = ProcessOut.shared
        let delegate = WebViewControllerDelegateAlternativePaymentMethod(
            alternativePaymentMethodsService: api.alternativePaymentMethods,
            request: request,
            completion: { [completion] result in
                completion?(result)
            }
        )
        let configuration = WebViewControllerConfiguration(
            returnUrls: [api.configuration.checkoutBaseUrl],
            version: type(of: api).version,
            timeout: nil
        )
        let viewController = WebViewController(
            configuration: configuration,
            delegate: delegate,
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
}
