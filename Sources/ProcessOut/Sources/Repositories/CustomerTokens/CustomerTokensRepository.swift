//
//  CustomerTokensRepository.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 27/10/2022.
//

protocol CustomerTokensRepository: PORepository {

    /// Create customer token.
    func createCustomerToken(request: POCreateCustomerTokenRequest) async throws -> POCustomerToken

    /// Assigns a token to a customer.
    func assignCustomerToken(request: POAssignCustomerTokenRequest) async throws -> AssignCustomerTokenResponse

    /// Tokenize alternative payment.
    func tokenize(
        request: PONativeAlternativePaymentTokenizationRequestV2
    ) async throws -> PONativeAlternativePaymentTokenizationResponseV2

    /// Deletes given customer token.
    func delete(request: PODeleteCustomerTokenRequest) async throws
}
