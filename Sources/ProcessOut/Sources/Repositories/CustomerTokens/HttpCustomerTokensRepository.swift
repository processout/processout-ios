//
//  HttpCustomerTokensRepository.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 27/10/2022.
//

import Foundation

final class HttpCustomerTokensRepository: CustomerTokensRepository {

    init(connector: any HttpConnector<Failure>) {
        self.connector = connector
    }

    // MARK: - CustomerTokensRepository

    func assignCustomerToken(
        request: POAssignCustomerTokenRequest
    ) async throws(Failure) -> AssignCustomerTokenResponse {
        let httpRequest = HttpConnectorRequest<AssignCustomerTokenResponse>.put(
            path: "/customers/\(request.customerId)/tokens/\(request.tokenId)",
            body: request,
            includesDeviceMetadata: true
        )
        return try await connector.execute(request: httpRequest)
    }

    func createCustomerToken(request: POCreateCustomerTokenRequest) async throws(Failure) -> POCustomerToken {
        struct Response: Decodable {
            let token: POCustomerToken
        }
        let httpRequest = HttpConnectorRequest<Response>.post(
            path: "/customers/\(request.customerId)/tokens",
            body: request,
            includesDeviceMetadata: true,
            requiresPrivateKey: true
        )
        return try await connector.execute(request: httpRequest).token
    }

    func delete(request: PODeleteCustomerTokenRequest) async throws(Failure) {
        let httpRequest = HttpConnectorRequest<VoidCodable>.delete(
            path: "/customers/\(request.customerId)/tokens/\(request.tokenId)",
            headers: ["X-Processout-Client-Secret": request.clientSecret]
        )
        _ = try await connector.execute(request: httpRequest)
    }

    // MARK: - Private Properties

    private let connector: any HttpConnector<Failure>
}
