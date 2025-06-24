//
//  POCustomerTokensServiceType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

@available(*, deprecated, renamed: "POCustomerTokensService")
public typealias POCustomerTokensServiceType = POCustomerTokensService

/// Provides an ability to interact with customer tokens.
///
/// You can only use a card or APM token once but you can make payments as many times as necessary with a customer
/// token. This is a useful way to store payment details for a customer as a convenience but it is also essential
/// for Merchant Initiated Transactions (MITs).
public protocol POCustomerTokensService: POService { // sourcery: AutoCompletion

    /// Creates customer token using given request.
    @_spi(PO)
    func createCustomerToken(request: POCreateCustomerTokenRequest) async throws -> POCustomerToken

    /// Assigns new source to existing customer token and optionally verifies it.
    func assignCustomerToken(
        request: POAssignCustomerTokenRequest, threeDSService: PO3DS2Service
    ) async throws -> POCustomerToken

    /// Tokenize alternative payment.
    @_spi(PO)
    func tokenize( // sourcery:completion: skip
        request: PONativeAlternativePaymentTokenizationRequestV2
    ) async throws -> PONativeAlternativePaymentTokenizationResponseV2

    /// Deletes customer token.
    func deleteCustomerToken(request: PODeleteCustomerTokenRequest) async throws
}

extension POCustomerTokensService {

    @_spi(PO)
    public func createCustomerToken(request: POCreateCustomerTokenRequest) async throws -> POCustomerToken {
        throw POFailure(code: .Mobile.generic)
    }

    @_spi(PO)
    public func tokenize( // sourcery:completion: skip
        request: PONativeAlternativePaymentTokenizationRequestV2
    ) async throws -> PONativeAlternativePaymentTokenizationResponseV2 {
        throw POFailure(code: .Mobile.generic)
    }
}
