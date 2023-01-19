//
//  CustomerTokensRepository.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 27/10/2022.
//

import Foundation

final class CustomerTokensRepository: CustomerTokensRepositoryType {

    init(connector: HttpConnectorType, failureMapper: FailureMapperType) {
        self.connector = connector
        self.failureMapper = failureMapper
    }

    // MARK: - CustomerTokensRepositoryType

    func assignCustomerToken(
        request: POAssignCustomerTokenRequest, completion: @escaping (Result<_CustomerAction?, Failure>) -> Void
    ) {
        struct Response: Decodable {
            let customerAction: _CustomerAction?
        }
        let httpRequest = HttpConnectorRequest<Response>.put(
            path: "/customers/\(request.customerId)/tokens/\(request.tokenId)",
            body: request,
            includesDeviceMetadata: true
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map(\.customerAction).mapError(failureMapper.failure))
        }
    }

    func createCustomerToken(
        request: POCustomerTokenCreationRequest,
        completion: @escaping (Result<POCustomerToken, Failure>) -> Void
    ) {
        struct Response: Decodable {
            let token: POCustomerToken
        }
        let httpRequest = HttpConnectorRequest<Response>.post(
            path: "/customers/\(request.customerId)/tokens", body: request, includesDeviceMetadata: true
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map(\.token).mapError(failureMapper.failure))
        }
    }

    // MARK: - Private Properties

    private let connector: HttpConnectorType
    private let failureMapper: FailureMapperType
}
