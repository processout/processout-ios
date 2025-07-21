//
//  DynamicCheckoutRegularPaymentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 06.06.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@MainActor
struct DynamicCheckoutRegularPaymentView: View {

    let item: DynamicCheckoutViewModelItem.RegularPayment

    var body: some View {
        VStack(spacing: POSpacing.large) {
            DynamicCheckoutRegularPaymentInfoView(item: item.info)
            if case .card(let item) = item.content {
                POCardTokenizationView(viewModel: item.viewModel())
                    .cardTokenizationPresentationContext(.inline)
                    .id(item.id)
            } else if case .alternativePayment(let item) = item.content {
                DynamicCheckoutAlternativePaymentView(item: item)
                    .id(item.id)
            }
            if let button = item.submitButton {
                Button.create(with: button)
                    .buttonStyle(POAnyButtonStyle(erasing: style.actionsContainer.primary))
            }
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
