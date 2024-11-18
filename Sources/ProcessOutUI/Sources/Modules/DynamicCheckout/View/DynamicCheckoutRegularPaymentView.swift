//
//  DynamicCheckoutRegularPaymentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 06.06.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
@MainActor
struct DynamicCheckoutRegularPaymentView: View {

    let item: DynamicCheckoutViewModelItem.RegularPayment

    var body: some View {
        VStack(spacing: POSpacing.large) {
            DynamicCheckoutRegularPaymentInfoView(item: item.info)
            if case .card(let item) = item.content {
                DynamicCheckoutCardView(item: item)
                    .id(item.id)
            } else if case .alternativePayment(let item) = item.content {
                DynamicCheckoutAlternativePaymentView(item: item)
                    .id(item.id)
            }
            DynamicCheckoutPaymentMethodButtonsView(
                buttons: [item.submitButton].compactMap { $0 }
            )
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
