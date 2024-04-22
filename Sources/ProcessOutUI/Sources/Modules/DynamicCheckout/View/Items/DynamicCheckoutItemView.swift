//
//  DynamicCheckoutItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 21.03.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct DynamicCheckoutItemView<ViewRouter>: View where ViewRouter: Router<DynamicCheckoutRoute> {

    let item: DynamicCheckoutViewModelItem
    let router: ViewRouter

    var body: some View {
        let padding = POSpacing.medium
        switch item {
        case .progress:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(padding)
        case .passKitPayment(let item):
            POPassKitPaymentButton(action: item.action)
                .padding(.horizontal, padding)
        case .expressPayment(let item):
            DynamicCheckoutExpressPaymentItemView(item: item)
                .padding(.horizontal, padding)
        case .payment(let item):
            DynamicCheckoutPaymentItemView(item: item)
                .padding(.horizontal, padding)
        case .card:
            router.view(for: .card)
        case .alternativePayment(let item):
            router.view(for: .nativeAlternativePayment(gatewayConfigurationId: item.gatewayConfigurationId))
        }
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
