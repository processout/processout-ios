//
//  FeaturesRoute.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import ProcessOut
@_spi(PO) import ProcessOutUI

enum FeaturesRoute: RouteType {

    /// Available gateway configurations.
    case gatewayConfigurations(filter: POAllGatewayConfigurationsRequest.Filter)

    /// Card tokenization form.
    case cardTokenization(threeDSService: CardPayment3DSService, completion: (Result<POCard, POFailure>) -> Void)

    /// Dynamic checkout flow.
    case dynamicCheckout(configuration: PODynamicCheckoutConfiguration, delegate: PODynamicCheckoutDelegate)

    /// Alert with given message.
    case alert(message: String)
}
