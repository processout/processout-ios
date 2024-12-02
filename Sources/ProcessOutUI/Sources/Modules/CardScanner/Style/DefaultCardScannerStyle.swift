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

        public init(backgroundColor: Color, border: POBorderStyle) {
            self.backgroundColor = backgroundColor
            self.border = border
        }
    }

    /// Title style.
    public let title: POTextStyle

    /// Description style.
    public let description: POTextStyle

    /// Video preview style.
    public let videoPreview: VideoPreview

    /// Cancel button style.
    public let cancelButton: any ButtonStyle

    public init(
        title: POTextStyle,
        description: POTextStyle,
        videoPreview: VideoPreview,
        cancelButton: any ButtonStyle
    ) {
        self.title = title
        self.description = description
        self.videoPreview = videoPreview
        self.cancelButton = cancelButton
    }

    // MARK: - POCardUpdateView

    public func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: POSpacing.medium) {
            VStack(spacing: POSpacing.small) {
                configuration.title
                    .textStyle(title)
                configuration.description
                    .textStyle(description)
            }
            configuration.videoPreview
                .background(videoPreview.backgroundColor)
                .border(style: videoPreview.border)
            configuration.cancelButton
                .buttonStyle(POAnyButtonStyle(erasing: cancelButton))
        }
        .padding(POSpacing.medium)
    }
}
