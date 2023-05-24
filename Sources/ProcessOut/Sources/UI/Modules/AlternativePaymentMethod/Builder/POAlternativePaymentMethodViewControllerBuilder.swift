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

    @available(*, deprecated, message: "Use non static method instead.")
    public static func with(
        request: POAlternativePaymentMethodRequest
    ) -> POAlternativePaymentMethodViewControllerBuilder {
        POAlternativePaymentMethodViewControllerBuilder().with(request: request)
    }

    /// Creates builder instance.
    public init() { }

    /// Request to initiate payment with.
    public func with(request: POAlternativePaymentMethodRequest) -> Self {
        self.request = request
        return self
    }

    /// Completion to invoke when authorization ends.
    public func with(completion: @escaping (Result<POAlternativePaymentMethodResponse, POFailure>) -> Void) -> Self {
        self.completion = completion
        return self
    }

    /// Creates and returns view controller that is capable of handling alternative payment request.
    public func build() -> UIViewController {
        guard let request else {
            preconditionFailure("Request must be set.")
        }
        let api: ProcessOut = ProcessOut.shared // swiftlint:disable:this redundant_type_annotation
        let delegate = WebViewControllerDelegateAlternativePaymentMethod(
            alternativePaymentMethodsService: api.alternativePaymentMethods,
            request: request,
            completion: { [completion] result in
                completion?(result)
            }
        )
        let configuration = WebViewControllerConfiguration(
            returnUrls: [api.configuration.checkoutBaseUrl],
            version: ProcessOut.version,
            timeout: nil
        )
        let viewController = WebViewController(
            configuration: configuration,
            delegate: delegate,
            logger: api.logger
        )
        return viewController
    }

    // MARK: - Private Properties

    private var request: POAlternativePaymentMethodRequest?
    private var completion: ((Result<POAlternativePaymentMethodResponse, POFailure>) -> Void)?
}
