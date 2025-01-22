//
//  PODefaultContentUnavailableViewStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.01.2025.
//

import SwiftUI

/// The default content unavailable view style.
@available(iOS 14, *)
public struct PODefaultContentUnavailableViewStyle: POContentUnavailableViewStyle {

    /// Label style.
    public let title: POTextStyle

    /// Description text style.
    public let description: POTextStyle

    public init(title: POTextStyle, description: POTextStyle) {
        self.title = title
        self.description = description
    }

    // MARK: - POContentUnavailableViewStyle

    public func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: POSpacing.extraSmall) {
            configuration
                .label
                .textStyle(title)
            configuration.description
                .textStyle(description)
        }
        .multilineTextAlignment(.center)
        .labelStyle(
            DefaultContentUnavailableViewLabelStyle(title: title, description: description)
        )
        .padding(POSpacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@available(iOS 14, *)
extension POContentUnavailableViewStyle where Self == PODefaultContentUnavailableViewStyle {

    /// The default content unavailable view style.
    public static var automatic: PODefaultContentUnavailableViewStyle {
        PODefaultContentUnavailableViewStyle(
            title: .init(
                color: Color(poResource: .Text.primary), typography: .Text.s16(weight: .medium)
            ),
            description: .init(
                color: Color(poResource: .Text.secondary), typography: .Text.s14(weight: .regular)
            )
        )
    }
}
