//
//  CustomerTokensRepository.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 27/10/2022.
//

import Foundation

final class CustomerTokensRepository: CustomerTokensRepositoryType {

    init(connector: HttpConnectorType, failureMapper: RepositoryFailureMapperType) {
        self.connector = connector
        self.failureMapper = failureMapper
    }

    // MARK: - CustomerTokensRepositoryType

    func assignCustomerToken(
        request: POAssignCustomerTokenRequest, completion: @escaping (Result<CustomerAction?, Failure>) -> Void
    ) {
        struct Response: Decodable {
            let customerAction: CustomerAction?
        }
        let httpRequest = HttpConnectorRequest<Response>.put(
            path: "/customers/\(request.customerId)/tokens/\(request.tokenId)",
            body: request,
            includesDeviceMetadata: true
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map(\.customerAction).mapError(failureMapper.repositoryFailure))
        }
    }

    // MARK: - Private Properties

    private let connector: HttpConnectorType
    private let failureMapper: RepositoryFailureMapperType
}
