//
//  POGatewayConfigurationsRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

import Foundation

public protocol POGatewayConfigurationsRepository: PORepository {

    /// Returns available gateway configurations.
    func all(
        request: POAllGatewayConfigurationsRequest,
        completion: @escaping (Result<POAllGatewayConfigurationsResponse, Failure>) -> Void
    )

    /// Searches configuration with given request.
    func find(
        request: POFindGatewayConfigurationRequest,
        completion: @escaping (Result<POGatewayConfiguration, Failure>) -> Void
    )
}

extension POGatewayConfigurationsRepository {

    /// Returns available gateway configurations.
    public func all(completion: @escaping (Result<POAllGatewayConfigurationsResponse, Failure>) -> Void) {
        all(request: POAllGatewayConfigurationsRequest(), completion: completion)
    }
}
