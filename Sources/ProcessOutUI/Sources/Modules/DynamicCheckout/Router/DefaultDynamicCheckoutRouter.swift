//
//  DefaultDynamicCheckoutRouter.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import SwiftUI

@available(iOS 14, *)
struct DefaultDynamicCheckoutRouter: Router {

    /// Configuration.
    let configuration: PODynamicCheckoutConfiguration

    /// Card tokenization delegate.
    weak var cardTokenizationDelegate: POCardTokenizationDelegate?

    @ViewBuilder
    func view(for route: DynamicCheckoutRoute) -> some View {
        // todo(andrii-vysotskyi): finish routes configuration
        switch route {
        case .card:
            let cardTokenizationConfiguration = POCardTokenizationConfiguration(
                title: "",
                isCardholderNameInputVisible: configuration.card.isCardholderNameInputVisible,
                primaryActionTitle: "",
                cancelActionTitle: "",
                billingAddress: configuration.card.billingAddress,
                metadata: configuration.card.metadata
            )
            POCardTokenizationView(
                configuration: cardTokenizationConfiguration,
                delegate: cardTokenizationDelegate,
                completion: { _ in /* Ignored */ }
            )
        case .alternativePayment:
            EmptyView()
        }
    }
}
