//
//  HttpCustomerTokensRepository.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 27/10/2022.
//

import Foundation

final class HttpCustomerTokensRepository: CustomerTokensRepository {

    init(connector: HttpConnector) {
        self.connector = connector
    }

    // MARK: - CustomerTokensRepository

    func createCustomerToken(request: POCreateCustomerTokenRequest) async throws -> POCustomerToken {
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

    func assignCustomerToken(request: POAssignCustomerTokenRequest) async throws -> AssignCustomerTokenResponse {
        let httpRequest = HttpConnectorRequest<AssignCustomerTokenResponse>.put(
            path: "/customers/\(request.customerId)/tokens/\(request.tokenId)",
            body: request,
            locale: request.localeIdentifier,
            includesDeviceMetadata: true,
        )
        return try await connector.execute(request: httpRequest)
    }

    func tokenize(
        request: PONativeAlternativePaymentTokenizationRequestV2
    ) async throws -> PONativeAlternativePaymentTokenizationResponseV2 {
        let httpRequest = HttpConnectorRequest<PONativeAlternativePaymentTokenizationResponseV2>.post(
            path: "/customers/\(request.customerId)/apm-tokens/\(request.customerTokenId)/tokenize",
            body: request,
            locale: request.localeIdentifier
        )
        return try await connector.execute(request: httpRequest)
    }

    func delete(request: PODeleteCustomerTokenRequest) async throws {
        let httpRequest = HttpConnectorRequest<VoidCodable>.delete(
            path: "/customers/\(request.customerId)/tokens/\(request.tokenId)",
            headers: ["X-Processout-Client-Secret": request.clientSecret],
            locale: request.localeIdentifier
        )
        _ = try await connector.execute(request: httpRequest)
    }

    // MARK: - Private Properties

    private let connector: HttpConnector
}
