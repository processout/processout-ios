//
//  PODefaultSavedPaymentMethodsStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// The default card scanner style.
@available(iOS 14, *)
public struct PODefaultSavedPaymentMethodsStyle: POSavedPaymentMethodsStyle {

    /// Title style.
    public let title: POTextStyle

    /// Border style.
    public let border: POBorderStyle

    public init(title: POTextStyle, border: POBorderStyle) {
        self.title = title
        self.border = border
    }

    // MARK: - POSavedPaymentMethodsStyle

    public func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 0) {
            HStack {
                configuration.title
                    .textStyle(title)
                Spacer()
            }
            .padding(POSpacing.large)
            Rectangle()
                .fill(border.color)
                .frame(height: 1)
            ScrollView {
                VStack(spacing: 0) {
                    Group(poSubviews: configuration.paymentMethods) { subviews in
                        ForEach(subviews) { subview in
                            subview
                            if subview.id != subviews.last?.id {
                                Rectangle()
                                    .fill(border.color)
                                    .frame(height: 1)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .border(style: border)
                .padding(POSpacing.large)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

// ._safeAreaInsets(EdgeInsets(top: 150, leading: 16, bottom: 16, trailing: 16))
