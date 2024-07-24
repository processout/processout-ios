//
//  DynamicCheckoutRegularPaymentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 06.06.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct DynamicCheckoutRegularPaymentView: View {

    let item: DynamicCheckoutViewModelItem.RegularPayment

    var body: some View {
        VStack(spacing: POSpacing.large) {
            DynamicCheckoutRegularPaymentInfoView(item: item.info)
            if case .card(let item) = item.content {
                DynamicCheckoutCardView(item: item)
                    .id(self.item.contentId)
            } else if case .alternativePayment(let item) = item.content {
                DynamicCheckoutAlternativePaymentView(item: item)
                    .id(self.item.contentId)
            }
            if let item = item.submitButton {
                Button(item.title, action: item.action)
                    .disabled(!item.isEnabled)
                    .buttonLoading(item.isLoading)
                    .buttonStyle(POAnyButtonStyle(erasing: style.actionsContainer.primary))
            }
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
