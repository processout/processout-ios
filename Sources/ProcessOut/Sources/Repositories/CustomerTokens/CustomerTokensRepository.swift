//
//  CustomerTokensRepository.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 27/10/2022.
//

import Foundation

final class CustomerTokensRepository: POCustomerTokensRepositoryType {
    init(
        connector: HttpConnectorType,
        failureFactory: RepositoryFailureFactoryType
    ) {
        self.connector = connector
        self.failureFactory = failureFactory
    }

    // MARK: - POCustomerTokensRepositoryType

    func assignCustomerToken(
        request: POCustomerTokensRequest,
        completion: @escaping (Result<POCustomerAction?, Failure>) -> Void
    ) {
        struct Response: Decodable {
            let customerAction: POCustomerAction?
        }
        let httpRequest = HttpConnectorRequest<Response>.put(
            path: "/customers/\(request.customerId)/tokens/\(request.tokenId)",
            body: request,
            includesDeviceMetadata: true
        )
        connector.execute(request: httpRequest) { [failureFactory] result in
            completion(result.map(\.customerAction).mapError(failureFactory.repositoryFailure))
        }
    }

    // MARK: - Private Properties

    private let connector: HttpConnectorType
    private let failureFactory: RepositoryFailureFactoryType
}
