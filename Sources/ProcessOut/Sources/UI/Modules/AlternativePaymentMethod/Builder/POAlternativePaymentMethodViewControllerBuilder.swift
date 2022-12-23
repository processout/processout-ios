//
//  POAlternativePaymentMethodViewControllerBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.11.2022.
//

import UIKit

@_spi(PO)
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

    /// Api that will be used by created module to communicate with BE. By default ``ProcessOutApi/shared``
    /// instance is used.
    public func with(api: ProcessOutApiType) -> Self {
        self.api = api
        return self
    }

    /// Creates and returns view controller that is capable of handling alternative payment request.
    public func build() -> UIViewController {
        let api: ProcessOutApiType = self.api ?? ProcessOutApi.shared
        let delegate = AlternativePaymentMethodWebViewControllerDelegate(
            alternativePaymentMethodsService: api.alternativePaymentMethods, request: request
        )
        let viewController = WebViewController(
            delegate: delegate,
            baseReturnUrl: api.configuration.checkoutBaseUrl,
            version: type(of: api).version,
            completion: completion
        )
        return viewController
    }

    // MARK: -

    init(request: POAlternativePaymentMethodRequest) {
        self.request = request
    }

    // MARK: - Private Properties

    private let request: POAlternativePaymentMethodRequest
    private var api: ProcessOutApiType?
    private var completion: ((Result<POAlternativePaymentMethodResponse, POFailure>) -> Void)?
}
