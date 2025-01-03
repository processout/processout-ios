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

    /// Border style.
    public let progressView: any ProgressViewStyle

    /// Cancel button style.
    public let cancelButton: any ButtonStyle

    public init(
        title: POTextStyle,
        border: POBorderStyle,
        progressView: some ProgressViewStyle,
        cancelButton: some ButtonStyle
    ) {
        self.title = title
        self.border = border
        self.progressView = progressView
        self.cancelButton = cancelButton
    }

    // MARK: - POSavedPaymentMethodsStyle

    public func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 0) {
            HStack {
                configuration.title
                    .textStyle(title)
                Spacer()
                configuration.cancelButton
                    .buttonStyle(POAnyButtonStyle(erasing: cancelButton))
                    .backport.poControlSize(.regular)
                    .controlWidth(.regular)
                    .offset(x: 14)
            }
            .padding(POSpacing.large)
            Rectangle()
                .fill(border.color)
                .frame(height: 1)
            ScrollView {
                Group {
                    if configuration.isLoading {
                        ProgressView()
                            .poProgressViewStyle(progressView)
                    } else {
                        makeBody(paymentMethods: configuration.paymentMethods)
                    }
                }
                .padding(POSpacing.large)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Private Properties

    @ViewBuilder
    private func makeBody(paymentMethods: AnyView) -> some View {
        Group(poSubviews: paymentMethods) { subviews in
            if !subviews.isEmpty {
                VStack(spacing: 0) {
                    ForEach(subviews) { subview in
                        subview
                        if subview.id != subviews.last?.id {
                            Rectangle()
                                .fill(border.color)
                                .frame(height: 1)
                        }
                    }
                }
                .compositingGroup()
                .border(style: border)
            }
        }
    }
}

// ._safeAreaInsets(EdgeInsets(top: 150, leading: 16, bottom: 16, trailing: 16))
