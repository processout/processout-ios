//
//  NativeAlternativePaymentSubmittedItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct NativeAlternativePaymentSubmittedItemView: View {

    let item: NativeAlternativePaymentViewModelItem.Submitted

    var body: some View {
        VStack(spacing: POSpacing.medium) {
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
                .multilineTextAlignment(isMessageCompact ? .center : .leading)
            Spacer()
                .frame(height: POSpacing.large)
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: min(Constants.maximumDecorationImageHeight, image.size.height))
                    .foregroundColor(descriptionStyle.color)
            }
        }
        .padding(.top, isMessageCompact ? Constants.topInset : POSpacing.large)
        .padding(.horizontal, POSpacing.large)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let maximumLogoImageHeight: CGFloat = 32
        static let maximumDecorationImageHeight: CGFloat = 260
        static let topInset: CGFloat = 68
        static let maximumCompactMessageLength = 150
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style

    // MARK: - Private Methods

    private var descriptionStyle: POTextStyle {
        item.isCaptured ? style.successMessage : style.message
    }

    private var isMessageCompact: Bool {
        item.message.count <= Constants.maximumCompactMessageLength
    }
}
