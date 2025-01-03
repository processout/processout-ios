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

    public struct Toolbar {

        /// Title style.
        public let title: POTextStyle

        /// Divider color.
        public let dividerColor: Color

        /// Toolbar background color.
        public let backgroundColor: Color

        public init(title: POTextStyle, dividerColor: Color, backgroundColor: Color) {
            self.title = title
            self.dividerColor = dividerColor
            self.backgroundColor = backgroundColor
        }
    }

    public struct Content {

        /// Border style.
        public let border: POBorderStyle

        /// Divider color.
        public let dividerColor: Color

        public init(border: POBorderStyle, dividerColor: Color) {
            self.border = border
            self.dividerColor = dividerColor
        }
    }

    /// Toolbar style.
    public let toolbar: Toolbar

    /// Content style.
    public let content: Content

    /// Border style.
    public let progressView: any ProgressViewStyle

    /// Message view style.
    public let messageView: any POMessageViewStyle

    /// Cancel button style.
    public let cancelButton: any ButtonStyle

    /// Background color.
    public let backgroundColor: Color

    public init(
        toolbar: Toolbar,
        content: Content,
        progressView: some ProgressViewStyle,
        messageView: some POMessageViewStyle,
        cancelButton: some ButtonStyle,
        backgroundColor: Color
    ) {
        self.toolbar = toolbar
        self.content = content
        self.progressView = progressView
        self.messageView = messageView
        self.cancelButton = cancelButton
        self.backgroundColor = backgroundColor
    }

    // MARK: - POSavedPaymentMethodsStyle

    public func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 0) {
            if #unavailable(iOS 15) {
                makeToolbarBody(configuration: configuration)
            }
            ScrollView {
                VStack(spacing: POSpacing.medium) {
                    configuration.message
                        .messageViewStyle(messageView)
                    if configuration.isLoading {
                        ProgressView()
                            .poProgressViewStyle(progressView)
                    } else {
                        makeContentBody(paymentMethods: configuration.paymentMethods)
                    }
                }
                .padding(POSpacing.large)
                .frame(maxWidth: .infinity)
            }
            .modify { content in
                if #available(iOS 15, *) {
                    content.safeAreaInset(edge: .top) {
                        makeToolbarBody(configuration: configuration)
                    }
                } else {
                    content
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor.ignoresSafeArea())
    }

    // MARK: - Private Properties

    @ViewBuilder
    private func makeContentBody(paymentMethods: AnyView) -> some View {
        Group(poSubviews: paymentMethods) { subviews in
            if !subviews.isEmpty {
                VStack(spacing: 0) {
                    ForEach(subviews) { subview in
                        subview
                        if subview.id != subviews.last?.id {
                            Rectangle()
                                .fill(content.dividerColor)
                                .frame(height: 1)
                        }
                    }
                }
                .compositingGroup()
                .border(style: content.border)
            }
        }
    }

    @ViewBuilder
    private func makeToolbarBody(configuration: Configuration) -> some View {
        VStack(spacing: 0) {
            HStack {
                configuration.title
                    .textStyle(toolbar.title)
                Spacer()
                configuration.cancelButton
                    .buttonStyle(POAnyButtonStyle(erasing: cancelButton))
                    .backport.poControlSize(.regular)
                    .controlWidth(.regular)
                    .offset(x: 14)
            }
            .padding(POSpacing.large)
            Rectangle()
                .fill(toolbar.dividerColor)
                .frame(height: 1)
        }
        .background(toolbar.backgroundColor)
    }
}

// ._safeAreaInsets(EdgeInsets(top: 150, leading: 16, bottom: 16, trailing: 16))
