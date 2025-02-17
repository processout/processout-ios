//
//  POGatewayConfigurationsRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

import Foundation

final class HttpGatewayConfigurationsRepository: POGatewayConfigurationsRepository {

    init(connector: any HttpConnector<Failure>) {
        self.connector = connector
    }

    // MARK: - POGatewayConfigurationsRepository

    func all(request: POAllGatewayConfigurationsRequest) async throws(Failure) -> POAllGatewayConfigurationsResponse {
        var query = request.paginationOptions?.queryItems ?? [:]
        query["filter"] = request.filter?.rawValue
        query["with_disabled"] = request.includeDisabled
        query["expand_merchant_accounts"] = true
        let request = HttpConnectorRequest<POAllGatewayConfigurationsResponse>.get(
            path: "/gateway-configurations", query: query
        )
        return try await connector.execute(request: request)
    }

    func find(request: POFindGatewayConfigurationRequest) async throws(Failure) -> POGatewayConfiguration {
        struct Response: Decodable, Sendable {
            let gatewayConfiguration: POGatewayConfiguration
        }
        let httpRequest = HttpConnectorRequest<Response>.get(
            path: "/gateway-configurations/" + request.id,
            query: [
                "expand": request.expand.map(\.rawValue).joined(separator: ",")
            ]
        )
        return try await connector.execute(request: httpRequest).gatewayConfiguration
    }

    // MARK: - Private Properties

    private let connector: any HttpConnector<Failure>
}
