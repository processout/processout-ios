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
public protocol POCustomerTokensService: POService {

    /// Assigns new source to existing customer token and optionaly verifies it.
    func assignCustomerToken(
        request: POAssignCustomerTokenRequest,
        threeDSService: PO3DSService,
        completion: @escaping (Result<POCustomerToken, POFailure>) -> Void
    )

    /// Creates customer token using given request.
    @_spi(PO)
    func createCustomerToken(
        request: POCreateCustomerTokenRequest, completion: @escaping (Result<POCustomerToken, Failure>) -> Void
    )
}

extension POCustomerTokensService {

    func createCustomerToken(
        request: POCreateCustomerTokenRequest, completion: @escaping (Result<POCustomerToken, Failure>) -> Void
    ) {
        let failure = POFailure(code: .generic(.mobile))
        completion(.failure(failure))
    }
}
