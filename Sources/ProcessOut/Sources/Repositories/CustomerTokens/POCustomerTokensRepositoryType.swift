//
//  POCustomerTokensRepositoryType.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 27/10/2022.
//

public protocol POCustomerTokensRepositoryType: PORepositoryType {

    /// Assigns a token to a customer.
    func assignCustomerToken(
        request: POCustomerTokensRequest, completion: @escaping (Result<POCustomerAction?, Failure>) -> Void
    )
}
