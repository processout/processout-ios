//
//  POGatewayConfigurationsRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

import Foundation

final class HttpGatewayConfigurationsRepository: POGatewayConfigurationsRepository {

    init(connector: HttpConnector, failureMapper: HttpConnectorFailureMapper) {
        self.connector = connector
        self.failureMapper = failureMapper
    }

    // MARK: - POGatewayConfigurationsRepository

    func all(
        request: POAllGatewayConfigurationsRequest,
        completion: @escaping (Result<POAllGatewayConfigurationsResponse, Failure>) -> Void
    ) {
        var query = request.paginationOptions?.queryItems ?? [:]
        query["filter"] = request.filter?.rawValue
        query["with_disabled"] = request.includeDisabled
        query["expand_merchant_accounts"] = true
        let request = HttpConnectorRequest<POAllGatewayConfigurationsResponse>.get(
            path: "/gateway-configurations", query: query
        )
        connector.execute(request: request) { [failureMapper] result in
            completion(result.mapError(failureMapper.failure))
        }
    }

    func find(
        request: POFindGatewayConfigurationRequest,
        completion: @escaping (Result<POGatewayConfiguration, Failure>) -> Void
    ) {
        struct Response: Decodable {
            let gatewayConfiguration: POGatewayConfiguration
        }
        let httpRequest = HttpConnectorRequest<Response>.get(
            path: "/gateway-configurations/" + request.id,
            query: [
                "expand": request.expand.map(\.rawValue).joined(separator: ",")
            ]
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map(\.gatewayConfiguration).mapError(failureMapper.failure))
        }
    }

    // MARK: - Private Properties

    private let connector: HttpConnector
    private let failureMapper: HttpConnectorFailureMapper
}
