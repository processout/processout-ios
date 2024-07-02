//
//  DynamicCheckoutPaymentSuccessView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 09.05.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct DynamicCheckoutPaymentSuccessView: View {

    let item: DynamicCheckoutViewModelItem.Success

    var body: some View {
        VStack(spacing: POSpacing.large) {
            Text(item.message)
                .textStyle(style.paymentSuccess.message)
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height: POSpacing.large)
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: min(Constants.maximumDecorationImageHeight, image.size.height))
                    .foregroundColor(style.paymentSuccess.message.color)
            }
        }
        .padding(POSpacing.large)
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
