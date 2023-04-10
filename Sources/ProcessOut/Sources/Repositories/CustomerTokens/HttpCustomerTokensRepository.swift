//
//  HttpCustomerTokensRepository.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 27/10/2022.
//

import Foundation

final class HttpCustomerTokensRepository: CustomerTokensRepository {

    init(connector: HttpConnector, failureMapper: HttpConnectorFailureMapper) {
        self.connector = connector
        self.failureMapper = failureMapper
    }

    // MARK: - CustomerTokensRepository

    func assignCustomerToken(
        request: POAssignCustomerTokenRequest,
        completion: @escaping (Result<AssignCustomerTokenResponse, Failure>) -> Void
    ) {
        let httpRequest = HttpConnectorRequest<AssignCustomerTokenResponse>.put(
            path: "/customers/\(request.customerId)/tokens/\(request.tokenId)",
            body: request,
            includesDeviceMetadata: true
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.mapError(failureMapper.failure))
        }
    }

    func createCustomerToken(
        request: POCreateCustomerTokenRequest,
        completion: @escaping (Result<POCustomerToken, Failure>) -> Void
    ) {
        struct Response: Decodable {
            let token: POCustomerToken
        }
        let httpRequest = HttpConnectorRequest<Response>.post(
            path: "/customers/\(request.customerId)/tokens",
            includesDeviceMetadata: true,
            requiresPrivateKey: true
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map(\.token).mapError(failureMapper.failure))
        }
    }

    // MARK: - Private Properties

    private let connector: HttpConnector
    private let failureMapper: HttpConnectorFailureMapper
}
