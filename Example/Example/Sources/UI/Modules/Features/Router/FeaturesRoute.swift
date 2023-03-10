//
//  FeaturesRoute.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import ProcessOut

enum FeaturesRoute: RouteType {
    case gatewayConfigurations(filter: POAllGatewayConfigurationsRequest.Filter)
    case cardDetails
}
