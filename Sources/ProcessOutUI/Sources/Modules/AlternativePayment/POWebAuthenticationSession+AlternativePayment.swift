//
//  POWebAuthenticationSession+AlternativePayment.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.03.2024.
//

import Foundation
import ProcessOut

extension POWebAuthenticationSession {

    /// Creates session that is capable of handling alternative payment.
    /// 
    /// - Parameters:
    ///   - request: Alternative payment request.
    ///   - returnUrl: Return URL specified when creating invoice.
    ///   - completion: Completion to invoke when APM flow completes.
    public convenience init(
        request: POAlternativePaymentMethodRequest,
        returnUrl: URL,
        completion: @escaping (Result<POAlternativePaymentMethodResponse, POFailure>) -> Void
    ) {
        let url = ProcessOut.shared.alternativePaymentMethods.alternativePaymentMethodUrl(request: request)
        self.init(alternativePaymentMethodUrl: url, returnUrl: returnUrl, completion: completion)
    }

    /// Creates session that is capable of handling alternative payment.
    ///
    /// - Parameters:
    ///   - url: initial URL instead of **request**. Implementation does not validate
    ///   whether given value is valid to actually start APM flow.
    ///   - returnUrl: Return URL specified when creating invoice.
    ///   - completion: Completion to invoke when APM flow completes.
    public convenience init(
        alternativePaymentMethodUrl url: URL,
        returnUrl: URL,
        completion: @escaping (Result<POAlternativePaymentMethodResponse, POFailure>) -> Void
    ) {
        let completionBox: Completion = { result in
            completion(result.flatMap(Self.response(with:)))
        }
        self.init(url: url, callback: .customScheme(returnUrl.scheme ?? ""), completion: completionBox)
    }

    // MARK: - Private Methods

    private static func response(with url: URL) -> Result<POAlternativePaymentMethodResponse, POFailure> {
        let result = Result {
            try ProcessOut.shared.alternativePaymentMethods.alternativePaymentMethodResponse(url: url)
        }
        return result.mapError { $0 as! POFailure } // swiftlint:disable:this force_cast
    }
}
