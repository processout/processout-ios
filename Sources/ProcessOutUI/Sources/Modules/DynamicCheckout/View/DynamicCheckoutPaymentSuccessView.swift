//
//  DynamicCheckoutPaymentSuccessView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 09.05.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@MainActor
struct DynamicCheckoutPaymentSuccessView: View {

    let item: DynamicCheckoutViewModelItem.Success

    // MARK: - View

    var body: some View {
        VStack(spacing: POSpacing.space6) {
            Image(poResource: .success)
            Text(item.title)
                .textStyle(style.paymentSuccess.title)
            Text(item.message)
                .textStyle(style.paymentSuccess.message)
        }
        .multilineTextAlignment(.center)
        .padding(.top, POSpacing.space28)
        .frame(maxWidth: .infinity)
        .backport.geometryGroup()
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let maximumDecorationImageHeight: CGFloat = 260
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
