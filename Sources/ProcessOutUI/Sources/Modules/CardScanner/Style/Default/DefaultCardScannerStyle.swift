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
@_spi(PO)
public struct PODefaultCardScannerStyle: POCardScannerStyle {

    public struct VideoPreview {

        /// Background color.
        public let backgroundColor: Color

        /// Border style.
        public let border: POBorderStyle

        /// Video preview overlay color.
        public let overlayColor: Color

        public init(backgroundColor: Color, border: POBorderStyle, overlayColor: Color) {
            self.backgroundColor = backgroundColor
            self.border = border
            self.overlayColor = overlayColor
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
        videoPreview: VideoPreview,
        card: Card,
        cancelButton: any ButtonStyle,
        backgroundColor: Color
    ) {
        self.title = title
        self.description = description
        self.videoPreview = videoPreview
        self.card = card
        self.cancelButton = cancelButton
        self.backgroundColor = backgroundColor
    }

    // MARK: - POCardScannerStyle

    public func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: POSpacing.medium) {
            VStack(spacing: POSpacing.small) {
                configuration.title
                    .textStyle(title)
                configuration.description
                    .textStyle(description)
            }
            .multilineTextAlignment(.center)
            configuration.videoPreview
                .background(videoPreview.backgroundColor)
                .backport.overlay {
                    makeBody(cardConfiguration: configuration.card)
                }
                .border(style: videoPreview.border)
            configuration.cancelButton
                .buttonStyle(POAnyButtonStyle(erasing: cancelButton))
                .backport.poControlSize(.small)
        }
        .padding(POSpacing.medium)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
    }

    // MARK: - Private Methods

    @ViewBuilder
    private func makeBody(cardConfiguration configuration: Configuration.Card?) -> some View {
        ZStack {
            videoPreview.overlayColor
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .invertMask {
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .border(style: card.border)
                        .padding(POSpacing.large)
                }
            VStack(alignment: .leading, spacing: POSpacing.small) {
                configuration?.number
                    .tracking(card.number.typography.font.pointSize * 0.05)
                    .textStyle(card.number)
                    .minimumScaleFactor(0.01)
                HStack(alignment: .bottom, spacing: POSpacing.small) {
                    configuration?.cardholderName?
                        .tracking(card.cardholderName.typography.font.pointSize * 0.05)
                        .textStyle(card.cardholderName)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    configuration?.expiration?
                        .tracking(card.expiration.typography.font.pointSize * 0.05)
                        .textStyle(card.expiration)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .lineLimit(1)
            .allowsTightening(true)
            .padding(POSpacing.extraLarge)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .border(style: card.border)
            .padding(POSpacing.large)
        }
    }
}
