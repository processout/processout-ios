//
//  DynamicCheckoutRegularPaymentInfoView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 22.03.2024.
//

import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

@MainActor
struct DynamicCheckoutRegularPaymentInfoView: View {

    let item: DynamicCheckoutViewModelItem.RegularPaymentInfo

    var body: some View {
        VStack(spacing: POSpacing.large) {
            HStack(spacing: POSpacing.small) {
                // todo(andrii-vysotskyi): decide if separate style should exist for AsyncImage
                POAsyncImage(resource: item.iconImageResource) {
                    style.regularPaymentMethod.title.color
                        .clipShape(RoundedRectangle(cornerRadius: POSpacing.extraSmall))
                }
                .frame(width: 24, height: 24)
                Text(item.title)
                    .lineLimit(1)
                    .textStyle(style.regularPaymentMethod.title)
                Spacer()
                if item.isLoading {
                    ProgressView()
                        .poProgressViewStyle(style.progressView)
                }
                Button(
                    action: {
                        item.isSelected = true
                    },
                    label: { }
                )
                .buttonStyle(
                    POAnyButtonStyle(erasing: style.radioButton)
                )
                .controlSize(.small)
                .controlSelected(item.isSelected)
            }
            .animation(.default, value: item.isLoading)
            if let information = item.additionalInformation {
                body(information: information)
            }
            if let binding = item.shouldSave {
                Toggle(String(resource: .DynamicCheckout.savePaymentMessage), isOn: binding)
                    .poToggleStyle(style.toggle)
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
                    .textStyle(style.regularPaymentMethod.informationText)
            },
            icon: {
                Image(poResource: .info)
                    .renderingMode(.template)
                    .foregroundColor(style.regularPaymentMethod.informationText.color)
            }
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
