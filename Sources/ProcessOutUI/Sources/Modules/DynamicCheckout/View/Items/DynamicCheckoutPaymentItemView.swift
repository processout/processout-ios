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
        VStack {
            HStack {
                POAsyncImage(resource: item.iconImageResource) {
                    Color(item.brandColor).frame(width: 24, height: 24)
                }
                Text(item.title)
                    .lineLimit(1)
                    .textStyle(style.subsection.title)
                Spacer()
                Button(
                    action: {
                        item.isSelected = true
                    },
                    label: {
                        EmptyView()
                    }
                )
                .buttonStyle(POAnyButtonStyle(erasing: style.radioButton))
                .radioButtonSelected(item.isSelected)
            }
            if let information = item.additionalInformation {
                body(information: information)
            }
        }
        .contentShape(.rect)
        .onTapGesture {
            item.isSelected = true
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.layoutDirection)
    private var layoutDirection

    @Environment(\.dynamicCheckoutStyle)
    private var style

    // MARK: - Private Methods

    @ViewBuilder
    private func body(information: String) -> some View {
        Label(
            title: {
                Text(information)
                    .textStyle(style.subsection.informationText)
            },
            icon: {
                Image(.info)
                    .renderingMode(.template)
                    .foregroundColor(style.subsection.informationText.color)
            }
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
