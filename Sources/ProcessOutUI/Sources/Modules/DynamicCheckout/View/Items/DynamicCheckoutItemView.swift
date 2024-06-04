//
//  DynamicCheckoutItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 21.03.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct DynamicCheckoutItemView: View {

    let item: DynamicCheckoutViewModelItem

    var body: some View {
        switch item {
        case .progress:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(POSpacing.medium)
                .poProgressViewStyle(style.progressView)
        case .passKitPayment(let item):
            POPassKitPaymentButton(type: item.buttonType, action: item.action)
                .passKitPaymentButtonStyle(style.passKitPaymentButtonStyle)
        case .expressPayment(let item):
            DynamicCheckoutExpressPaymentItemView(item: item)
                .buttonStyle(POAnyButtonStyle(erasing: style.expressPaymentButtonStyle))
        case .payment(let item):
            DynamicCheckoutPaymentInfoItemView(item: item)
        case .card(let item):
            DynamicCheckoutCardItemView(item: item)
        case .alternativePayment(let item):
            DynamicCheckoutAlternativePaymentItemView(item: item)
        case .message(let item):
            POMessageView(message: item)
                .messageViewStyle(style.message)
        case .success(let item):
            DynamicCheckoutSuccessItemView(item: item)
        }
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
