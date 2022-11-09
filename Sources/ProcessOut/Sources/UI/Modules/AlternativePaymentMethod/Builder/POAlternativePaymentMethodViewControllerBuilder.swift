//
//  POAlternativePaymentMethodViewControllerBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.11.2022.
//

import UIKit

public final class POAlternativePaymentMethodViewControllerBuilder {

    public static func with(request: POAlternativePaymentMethodRequest, returnUrl: URL) -> Self {
        Self(request: request, returnUrl: returnUrl)
    }

    /// Completion to invoke when authorization ends.
    public func with(
        completion: @escaping (Result<POAlternativePaymentMethodResponse, PORepositoryFailure>) -> Void
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
        let viewController = AlternativePaymentMethodViewController(
            alternativePaymentMethodsService: api.alternativePaymentMethods,
            request: request,
            returnUrl: returnUrl,
            completion: completion
        )
        return viewController
    }

    // MARK: -

    init(request: POAlternativePaymentMethodRequest, returnUrl: URL) {
        self.request = request
        self.returnUrl = returnUrl
    }

    // MARK: - Private Properties

    private let request: POAlternativePaymentMethodRequest
    private let returnUrl: URL

    private var api: ProcessOutApiType?
    private var completion: ((Result<POAlternativePaymentMethodResponse, PORepositoryFailure>) -> Void)?
}
