//
//  POAllGatewayConfigurationsResponse.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

public struct POAllGatewayConfigurationsResponse: Decodable {

    /// Boolean flag indicating whether there are more items to fetch.
    public let hasMore: Bool

    /// Total count of items.
    public let totalCount: Int

    /// Available gateway configurations.
    public let gatewayConfigurations: [POGatewayConfiguration]
}
