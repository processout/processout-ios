//
//  DynamicCheckoutRoute.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.02.2024.
//

enum DynamicCheckoutRoute: Hashable {

    struct AlternativePayment: Hashable {

        /// Gateway configuration id that should be used to initiate native alternative payment.
        let gatewayConfigurationId: String
    }

    /// Payment card details.
    case card

    /// Native alternative payment.
    case alternativePayment(AlternativePayment)
}
