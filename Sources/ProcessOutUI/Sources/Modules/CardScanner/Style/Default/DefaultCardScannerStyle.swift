//
//  DefaultCardScannerStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.12.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// The default card scanner style.
@available(iOS 14, *)
public struct PODefaultCardScannerStyle: POCardScannerStyle {

    public struct VideoPreview {

        /// Background color.
        public let backgroundColor: Color

        /// Border style.
        public let border: POBorderStyle

        /// Video preview overlay color.
        public let overlayColor: Color

        /// Video preview overlay insets.
        public let overlayInsets: EdgeInsets

        public init(
            backgroundColor: Color,
            border: POBorderStyle,
            overlayColor: Color,
            overlayInsets: EdgeInsets? = nil
        ) {
            self.backgroundColor = backgroundColor
            self.border = border
            self.overlayColor = overlayColor
            self.overlayInsets = overlayInsets ?? .init(horizontal: POSpacing.large, vertical: POSpacing.large)
        }
    }

    public struct Card {

        /// Number text style.
        public let number: POTextStyle

        /// Cardholder name text style.
        public let cardholderName: POTextStyle

        /// Expiration text style.
        public let expiration: POTextStyle

        /// Card border style.
        public let border: POBorderStyle

        public init(number: POTextStyle, cardholderName: POTextStyle, expiration: POTextStyle, border: POBorderStyle) {
            self.number = number
            self.cardholderName = cardholderName
            self.expiration = expiration
            self.border = border
        }
    }

    /// Title style.
    public let title: POTextStyle

    /// Description style.
    public let description: POTextStyle

    /// Torch toggle style.
    public let torchToggle: any ToggleStyle

    /// Video preview style.
    public let videoPreview: VideoPreview

    /// Detected card overlay style.
    public let card: Card

    /// Cancel button style.
    public let cancelButton: any ButtonStyle

    /// Background color.
    public let backgroundColor: Color

    public init(
        title: POTextStyle,
        description: POTextStyle,
        torchToggle: any ToggleStyle,
        videoPreview: VideoPreview,
        card: Card,
        cancelButton: any ButtonStyle,
        backgroundColor: Color
    ) {
        self.title = title
        self.description = description
        self.torchToggle = torchToggle
        self.videoPreview = videoPreview
        self.card = card
        self.cancelButton = cancelButton
        self.backgroundColor = backgroundColor
    }

    // MARK: - POCardScannerStyle

    public func makeBody(configuration: Configuration) -> some View {
        ScrollView {
            VStack(spacing: POSpacing.medium) {
                POToolbar(alignment: .top, spacing: POSpacing.small) {
                    configuration.torchToggle
                        .poToggleStyle(torchToggle)
                        .backport.poControlSize(.small)
                        .controlWidth(.regular)
                        .padding(.leading, POSpacing.extraSmall)
                } principal: {
                    VStack(spacing: POSpacing.small) {
                        configuration.title
                            .textStyle(title)
                        configuration.description
                            .textStyle(description)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, POSpacing.large)
                } trailing: {
                    EmptyView()
                }
                Color.clear
                    .aspectRatio(Constants.previewAspectRatio, contentMode: .fit)
                    .padding(videoPreview.overlayInsets)
                    .frame(maxWidth: .infinity)
                    .backport.overlay {
                        ZStack {
                            configuration.videoPreview
                            cardOverlay(with: configuration.card)
                        }
                    }
                    .background(videoPreview.backgroundColor)
                    .border(style: videoPreview.border)
                configuration.cancelButton
                    .buttonStyle(POAnyButtonStyle(erasing: cancelButton))
                    .backport.poControlSize(.small)
            }
            .padding(
                .init(
                    top: POSpacing.medium,
                    leading: POSpacing.medium,
                    bottom: POSpacing.extraLarge,
                    trailing: POSpacing.medium
                )
            )
            .frame(maxWidth: .infinity)
        }
        .backport.background {
            backgroundColor.ignoresSafeArea()
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let previewAspectRatio: CGFloat = 1.586 // ISO/IEC 7810 based
    }

    // MARK: - Private Methods

    @ViewBuilder
    private func cardOverlay(with configuration: Configuration.Card?) -> some View {
        ZStack {
            videoPreview.overlayColor
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .invertMask {
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .border(style: card.border)
                        .padding(videoPreview.overlayInsets)
                }
            cardDetails(with: configuration)
                .padding(POSpacing.extraLarge)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .border(style: card.border)
                .padding(videoPreview.overlayInsets)
        }
    }

    private func cardDetails(with configuration: Configuration.Card?) -> some View {
        VStack(alignment: .leading, spacing: POSpacing.small) {
            configuration?.number
                .tracking(card.number.typography.font.pointSize * 0.05)
                .textStyle(card.number)
                .animation(.default, value: configuration?.number == nil)
                .frame(maxHeight: .infinity, alignment: .bottom)
            HStack(alignment: .top, spacing: 0) {
                configuration?.cardholderName?
                    .tracking(card.cardholderName.typography.font.pointSize * 0.05)
                    .textStyle(card.cardholderName)
                    .lineLimit(2)
                    .layoutPriority(1)
                Spacer(minLength: POSpacing.large)
                configuration?.expiration?
                    .tracking(card.expiration.typography.font.pointSize * 0.05)
                    .textStyle(card.expiration)
                    .layoutPriority(1)
                Spacer(minLength: 0)
                    .frame(maxWidth: POSpacing.extraExtraLarge)
            }
            .animation(.default, value: configuration?.cardholderName == nil)
            .animation(.default, value: configuration?.expiration == nil)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .allowsTightening(true)
        .lineLimit(1)
        .minimumScaleFactor(0.01)
        .fontNumberSpacing(.monospaced)
        .colorScheme(.dark)
        .shadow(style: .init(color: .black.opacity(0.32), offset: .init(width: 0, height: 4), radius: 16))
        .shadow(style: .init(color: .black.opacity(0.32), offset: .init(width: 0, height: 1), radius: 4))
    }
}
