//
//  SFSafariViewController+AlternativePayment.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.11.2023.
//

import Foundation
import SafariServices
@_spi(PO) import ProcessOut

extension SFSafariViewController {

    /// Creates view controller that is capable of handling Alternative Payment.
    ///
    /// - Note: Caller should dismiss view controller after completion is called.
    /// - Note: Object's delegate shouldn't be modified.
    ///
    /// - Parameters:
    ///   - returnUrl: Return URL specified when creating invoice.
    ///   - safariConfiguration: The configuration for the new view controller.
    ///   - completion: Completion to invoke when APM flow completes.
    public convenience init(
        request: POAlternativePaymentMethodRequest,
        returnUrl: URL,
        safariConfiguration: SFSafariViewController.Configuration = Configuration(),
        completion: @escaping (Result<POAlternativePaymentMethodResponse, POFailure>) -> Void
    ) {
        let url = ProcessOut.shared.alternativePaymentMethods.alternativePaymentMethodUrl(request: request)
        self.init(url: url, configuration: safariConfiguration)
        commonInit(returnUrl: returnUrl, completion: completion)
    }

    /// Creates view controller that is capable of handling Alternative Payment.
    ///
    /// - Note: Caller should dismiss view controller after completion is called.
    /// - Note: Object's delegate shouldn't be modified.
    ///
    /// - Parameters:
    ///   - url: initial URL instead of **request**. Implementation does not validate
    ///   whether given value is valid to actually start APM flow.
    ///   - returnUrl: Return URL specified when creating invoice.
    ///   - safariConfiguration: The configuration for the new view controller.
    ///   - completion: Completion to invoke when APM flow completes.
    public convenience init(
        alternativePaymentMethodUrl url: URL,
        returnUrl: URL,
        safariConfiguration: SFSafariViewController.Configuration = Configuration(),
        completion: @escaping (Result<POAlternativePaymentMethodResponse, POFailure>) -> Void
    ) {
        self.init(url: url, configuration: safariConfiguration)
        commonInit(returnUrl: returnUrl, completion: completion)
    }

    // MARK: - Private Nested Types

    private typealias Completion = (Result<POAlternativePaymentMethodResponse, POFailure>) -> Void

    // MARK: - Private Methods

    private func commonInit(returnUrl: URL, completion: @escaping Completion) {
        let api: ProcessOut = ProcessOut.shared // swiftlint:disable:this redundant_type_annotation
        let viewModel = DefaultSafariViewModel(
            callback: .customScheme(returnUrl.scheme ?? ""),
            eventEmitter: api.eventEmitter,
            logger: api.logger,
            completion: { result in
                completion(result.flatMap(Self.response(with:)))
            }
        )
        self.setViewModel(viewModel)
        viewModel.start()
    }

    private static func response(with url: URL) -> Result<POAlternativePaymentMethodResponse, POFailure> {
        let result = Result {
            try ProcessOut.shared.alternativePaymentMethods.alternativePaymentMethodResponse(url: url)
        }
        return result.mapError { $0 as! POFailure } // swiftlint:disable:this force_cast
    }
}
