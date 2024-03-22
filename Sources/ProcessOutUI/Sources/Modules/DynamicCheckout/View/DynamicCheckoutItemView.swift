//
//  DynamicCheckoutItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 21.03.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct DynamicCheckoutItemView<ViewRouter: Router>: View where ViewRouter.Route == DynamicCheckoutRoute {

    let item: DynamicCheckoutViewModelItem
    let router: ViewRouter

    var body: some View {
        switch item {
        case .progress:
            ProgressView()
                .frame(maxWidth: .infinity)
        case .expressPayment:
            EmptyView()
        case .payment(let paymentItem):
            DynamicCheckoutPaymentItemView(item: paymentItem)
        case .card:
            router.view(for: .card)
        case .alternativePayment(let alternativePayment):
            let route = DynamicCheckoutRoute.AlternativePayment(
                gatewayConfigurationId: alternativePayment.gatewayConfigurationId
            )
            router.view(for: .alternativePayment(route))
        }
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
