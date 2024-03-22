//
//  DynamicCheckoutPaymentItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 22.03.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct DynamicCheckoutPaymentItemView: View {

    let item: DynamicCheckoutViewModelItem.Payment

    var body: some View {
        VStack(spacing: POSpacing.small) {
            Button(
                action: {
                    item.isSelected = true
                },
                label: {
                    Label(
                        title: {
                            Text(item.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        },
                        icon: {
                            item.iconImage.map(Image.init)
                        }
                    )
                    .environment(\.layoutDirection, layoutDirection) // Restore original direction
                }
            )
            .environment(\.layoutDirection, layoutDirection.inverted)
            .buttonStyle(.radio)
            if let information = item.additionalInformation {
                Label(
                    title: {
                        Text(information)
                            .textStyle(style.payment.informationText)
                    },
                    icon: {
                        Image(.info)
                            .renderingMode(.template)
                            .foregroundColor(style.payment.informationText.color)
                    }
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
    }

    // MARK: - Private Properties

    @Environment(\.layoutDirection)
    private var layoutDirection

    @Environment(\.dynamicCheckoutStyle)
    private var style
}

@available(iOS 14, *)
#Preview {
    DynamicCheckoutPaymentItemView(
        item: .init(
            id: "",
            iconImage: nil,
            title: "Hello",
            isSelected: .constant(true),
            additionalInformation: "You will be redirected to finalise this payment"
        )
    )
}
