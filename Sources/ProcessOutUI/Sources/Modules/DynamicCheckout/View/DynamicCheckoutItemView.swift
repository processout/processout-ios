//
//  DynamicCheckoutItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 21.03.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@MainActor
struct DynamicCheckoutItemView: View {

    let item: DynamicCheckoutViewModelItem

    // MARK: - View

    var body: some View {
        switch item {
        case .progress:
            ProgressView()
                .poProgressViewStyle(style.progressView)
                .frame(maxWidth: .infinity)
        case .passKitPayment(let item):
            POPassKitPaymentButton(type: item.buttonType, action: item.action)
                .passKitPaymentButtonStyle(style.passKitPaymentButtonStyle)
        case .expressPayment(let item):
            DynamicCheckoutExpressPaymentView(item: item)
        case .regularPayment(let item):
            DynamicCheckoutRegularPaymentView(item: item)
        case .message(let item):
            POMessageView(message: item)
                .messageViewStyle(style.message)
        case .success(let item):
            DynamicCheckoutPaymentSuccessView(item: item)
        }
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
