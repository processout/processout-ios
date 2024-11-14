//
//  DynamicCheckoutExpressPaymentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.04.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14.0, *)
struct DynamicCheckoutExpressPaymentView: View {

    let item: DynamicCheckoutViewModelItem.ExpressPayment

    // MARK: - View

    var body: some View {
        Button(action: item.action) {
            Label(
                title: {
                    Text(item.title)
                },
                icon: {
                    POAsyncImage(resource: item.iconImageResource) {
                        Color.clear.frame(width: 24, height: 24)
                    }
                }
            )
        }
        .buttonStyle(POAnyButtonStyle(erasing: style.expressPaymentButtonStyle))
        .disabled(item.isLoading)
        .buttonLoading(item.isLoading)
        .buttonBrandColor(item.brandColor)
        .fontNumberSpacing(.monospaced)
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
