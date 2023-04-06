//
//  CustomerTokensRepositoryType.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 27/10/2022.
//

protocol CustomerTokensRepositoryType: PORepositoryType {

    /// Assigns a token to a customer.
    func assignCustomerToken(
        request: POAssignCustomerTokenRequest,
        completion: @escaping (Result<AssignCustomerTokenResponse, Failure>) -> Void
    )

    /// Create customer token.
    func createCustomerToken(
        request: POCreateCustomerTokenRequest, completion: @escaping (Result<POCustomerToken, Failure>) -> Void
    )
}
