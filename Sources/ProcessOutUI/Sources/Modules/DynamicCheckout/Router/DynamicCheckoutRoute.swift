//
//  DynamicCheckoutRoute.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.02.2024.
//

enum DynamicCheckoutRoute: Hashable {

    /// Payment card details.
    case card

    /// Native alternative payment.
    case nativeAlternativePayment(gatewayConfigurationId: String)
}
