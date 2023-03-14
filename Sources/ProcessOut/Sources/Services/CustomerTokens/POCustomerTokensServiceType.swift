//
//  CustomerTokensServiceType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

@_spi(PO)
public protocol POCustomerTokensServiceType: POServiceType {

    /// Assigns new source to existing customer token using given request.
    func assignCustomerToken(
        request: POAssignCustomerTokenRequest,
        threeDSHandler: POThreeDSHandlerType,
        completion: @escaping (Result<Void, POFailure>) -> Void
    )

    /// Create customer token.
    @_spi(PO)
    func createCustomerToken(
        request: POCustomerTokenCreationRequest,
        completion: @escaping (Result<POCustomerToken, Failure>) -> Void
    )
}
