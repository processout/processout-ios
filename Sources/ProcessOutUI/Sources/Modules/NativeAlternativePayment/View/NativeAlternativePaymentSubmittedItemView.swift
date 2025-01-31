//
//  NativeAlternativePaymentSubmittedItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
@MainActor
struct NativeAlternativePaymentSubmittedItemView: View {

    let item: NativeAlternativePaymentViewModelItem.Submitted
    let horizontalPadding: CGFloat

    var body: some View {
        VStack(spacing: POSpacing.large) {
            if let title = item.title {
                Text(title)
                    .textStyle(POTextStyle(color: descriptionStyle.color, typography: style.title.typography))
                    .multilineTextAlignment(.center)
            }
            if let image = item.logoImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: min(Constants.maximumLogoImageHeight, image.size.height))
            }
            if !item.isProgressViewHidden {
                ProgressView()
                    .poProgressViewStyle(style.progressView)
            }
            POMarkdown(item.message)
                .textStyle(descriptionStyle)
                .multilineTextAlignment(item.isMessageCompact ? .center : .leading)
            if let image = item.image {
                let maximumHeight = sizeClass == .compact
                    ? Constants.compactDecorationHeight : Constants.regularDecorationHeight
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: min(maximumHeight, image.size.height))
                    .foregroundColor(descriptionStyle.color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, topPadding)
        .padding(.horizontal, horizontalPadding)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let maximumLogoImageHeight: CGFloat = 32
        static let regularDecorationHeight: CGFloat = 280
        static let compactDecorationHeight: CGFloat = 140
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style

    @Environment(\.nativeAlternativePaymentSizeClass)
    private var sizeClass

    // MARK: - Private Methods

    private var descriptionStyle: POTextStyle {
        item.isCaptured ? style.successMessage : style.message
    }

    private var topPadding: CGFloat {
        if !item.isMessageCompact {
            return 0
        } else if sizeClass == .compact {
            return POSpacing.large
        }
        return 68
    }
}
