//
//  POGatewayConfigurationsRepositoryType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

import Foundation

public protocol POGatewayConfigurationsRepositoryType: PORepositoryType, POAutoAsync {

    /// Returns available gateway configurations.
    func all(
        request: POAllGatewayConfigurationsRequest,
        completion: @escaping (Result<POAllGatewayConfigurationsResponse, Failure>) -> Void
    )

    /// Searches configuration with given id.
    func find(id: String, completion: @escaping (Result<POGatewayConfiguration, Failure>) -> Void)
}

extension POGatewayConfigurationsRepositoryType {

    /// Returns available gateway configurations.
    public func all(completion: @escaping (Result<POAllGatewayConfigurationsResponse, Failure>) -> Void) {
        all(request: POAllGatewayConfigurationsRequest(), completion: completion)
    }
}
