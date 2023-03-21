//
//  CustomerTokensServiceType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

public protocol POCustomerTokensServiceType: POServiceType {

    /// Assigns new source to existing customer token using given request.
    func assignCustomerToken(
        request: POAssignCustomerTokenRequest,
        threeDSService: PO3DSServiceType,
        completion: @escaping (Result<Void, POFailure>) -> Void
    )

    /// Create customer token.
    @_spi(PO)
    func createCustomerToken(
        request: POCreateCustomerTokenRequest, completion: @escaping (Result<POCustomerToken, Failure>) -> Void
    )
}

extension POCustomerTokensServiceType {

    func createCustomerToken(
        request: POCreateCustomerTokenRequest, completion: @escaping (Result<POCustomerToken, Failure>) -> Void
    ) {
        let failure = POFailure(code: .generic(.mobile))
        completion(.failure(failure))
    }
}
