//
//  POGatewayConfigurationsRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

import Foundation

public protocol POGatewayConfigurationsRepository: PORepository { // sourcery: AutoCompletion

    /// Returns available gateway configurations.
    func all(request: POAllGatewayConfigurationsRequest) async throws -> POAllGatewayConfigurationsResponse

    /// Searches configuration with given request.
    func find(request: POFindGatewayConfigurationRequest) async throws -> POGatewayConfiguration
}

extension POGatewayConfigurationsRepository {

    /// Returns available gateway configurations.
    public func all() async throws -> POAllGatewayConfigurationsResponse {
        let request = POAllGatewayConfigurationsRequest()
        return try await all(request: request)
    }
}
