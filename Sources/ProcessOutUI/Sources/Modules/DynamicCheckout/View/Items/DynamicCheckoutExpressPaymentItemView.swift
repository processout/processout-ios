//
//  DynamicCheckoutExpressPaymentItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.04.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14.0, *)
struct DynamicCheckoutExpressPaymentItemView: View {

    let item: DynamicCheckoutViewModelItem.ExpressPayment

    // MARK: - View

    var body: some View {
        Button(action: item.action) {
            Label(
                title: {
                    Text(item.title).lineLimit(1)
                },
                icon: {
                    POAsyncImage(resource: item.iconImageResource) {
                        Color(item.brandColor).frame(width: 24, height: 24)
                    }
                }
            )
        }
        // todo(andrii-vysotskyi): add button style that could work find with only brand color
        .buttonStyle(.primary)
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}