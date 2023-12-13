//
//  CustomerTokensRepository.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 27/10/2022.
//

protocol CustomerTokensRepository: PORepository {

    /// Assigns a token to a customer.
    func assignCustomerToken(request: POAssignCustomerTokenRequest) async throws -> AssignCustomerTokenResponse

    /// Create customer token.
    func createCustomerToken(request: POCreateCustomerTokenRequest) async throws -> POCustomerToken
}
