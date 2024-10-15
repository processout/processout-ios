//
//  POAlternativePaymentsService.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 27/10/2022.
//

import Foundation

@available(*, deprecated, renamed: "POAlternativePaymentsService")
public typealias POAlternativePaymentMethodsServiceType = POAlternativePaymentsService

@available(*, deprecated, renamed: "POAlternativePaymentsService")
public typealias POAlternativePaymentMethodsService = POAlternativePaymentsService

/// Service that provides set of methods to work with alternative payments.
public protocol POAlternativePaymentsService: POService {

    /// Attempts to tokenize APM using given request.
    ///
    /// - NOTE: The underlying implementation uses `ASWebAuthenticationSession`, which triggers its
    /// completion handler before dismissing the view controller. To avoid presentation issues, if you plan to perform
    /// any UI-related tasks immediately after this method completes, consider adding a delay.
    func tokenize(request: POAlternativePaymentTokenizationRequest) async throws -> POAlternativePaymentResponse

    /// Authorizes invoice using given request.
    ///
    /// - NOTE: The underlying implementation uses `ASWebAuthenticationSession`, which triggers its
    /// completion handler before dismissing the view controller. To avoid presentation issues, if you plan to perform
    /// any UI-related tasks immediately after this method completes, consider adding a delay.
    func authorize(request: POAlternativePaymentAuthorizationRequest) async throws -> POAlternativePaymentResponse

    /// Authenticates alternative payment using given raw URL.
    ///
    /// - NOTE: The underlying implementation uses `ASWebAuthenticationSession`, which triggers its
    /// completion handler before dismissing the view controller. To avoid presentation issues, if you plan to perform
    /// any UI-related tasks immediately after this method completes, consider adding a delay.
    func authenticate(using url: URL) async throws -> POAlternativePaymentResponse

    /// Creates redirect URL for given tokenization request.
    func url(for request: POAlternativePaymentTokenizationRequest) throws -> URL

    /// Creates redirect URL for given authorization request.
    func url(for request: POAlternativePaymentAuthorizationRequest) throws -> URL

    /// Creates the redirection URL for APM Payments and APM token creation.
    ///
    /// - Parameter request: request containing information needed to build the URL.
    @available(*, deprecated, message: "Use tokenize(request:) or authorize(request:) instead to process payment.")
    func alternativePaymentMethodUrl(request: POAlternativePaymentMethodRequest) -> URL

    /// Convert given APMs response URL into response object.
    ///
    /// - Parameter url: url response that our checkout service sends back when the customer gets redirected.
    /// - Returns: response parsed from given url.
    @available(*, deprecated, message: "Use tokenize(request:) or authorize(request:) instead to process payment.")
    func alternativePaymentMethodResponse(url: URL) throws -> POAlternativePaymentMethodResponse

    /// Replaces configuration.
    @_spi(PO)
    func replace(configuration: POAlternativePaymentsServiceConfiguration)
}
