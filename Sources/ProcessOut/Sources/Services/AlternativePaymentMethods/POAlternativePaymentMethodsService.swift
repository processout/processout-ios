//
//  POAlternativePaymentMethodsService.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 27/10/2022.
//

import Foundation

@available(*, deprecated, renamed: "POAlternativePaymentMethodsService")
public typealias POAlternativePaymentMethodsServiceType = POAlternativePaymentMethodsService

/// Service that provides set of methods to work with alternative payments.
public protocol POAlternativePaymentMethodsService: POService {

    /// Attempts to tokenize APM using given request.
    func tokenize(request: POAlternativePaymentTokenizationRequest) async throws -> POAlternativePaymentResponse

    /// Authorizes invoice using given request.
    func authorize(request: POAlternativePaymentAuthorizationRequest) async throws -> POAlternativePaymentResponse

    /// Authenticates alternative payment using given raw URL.
    func authenticate(using url: URL) async throws -> POAlternativePaymentResponse
}
