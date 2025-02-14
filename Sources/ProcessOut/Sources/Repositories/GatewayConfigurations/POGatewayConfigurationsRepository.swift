//
//  POGatewayConfigurationsRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

import Foundation

@available(*, deprecated, renamed: "POGatewayConfigurationsRepository")
public typealias POGatewayConfigurationsRepositoryType = POGatewayConfigurationsRepository

public protocol POGatewayConfigurationsRepository: PORepository { // sourcery: AutoCompletion

    /// Returns available gateway configurations.
    func all(request: POAllGatewayConfigurationsRequest) async throws(Failure) -> POAllGatewayConfigurationsResponse

    /// Searches configuration with given request.
    func find(request: POFindGatewayConfigurationRequest) async throws(Failure) -> POGatewayConfiguration
}

extension POGatewayConfigurationsRepository {

    /// Returns available gateway configurations.
    public func all() async throws(Failure) -> POAllGatewayConfigurationsResponse {
        let request = POAllGatewayConfigurationsRequest()
        return try await all(request: request)
    }
}
