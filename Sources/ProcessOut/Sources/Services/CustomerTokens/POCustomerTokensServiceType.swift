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
        customerActionHandlerDelegate: POCustomerActionHandlerDelegate,
        completion: @escaping (Result<Void, PORepositoryFailure>) -> Void
    )
}
