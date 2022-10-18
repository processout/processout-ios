//
//  ProcessOutApiType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

public protocol ProcessOutApiType {

    /// Returns gateway configurations repository.
    var gatewayConfigurations: POGatewayConfigurationsRepositoryType { get }
}
