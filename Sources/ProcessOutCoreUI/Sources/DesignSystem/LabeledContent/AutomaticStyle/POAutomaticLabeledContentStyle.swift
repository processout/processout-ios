//
//  POAutomaticLabeledContentStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2025.
//

import SwiftUI

/// The default labeled content style.
///
/// Use ``LabeledContentStyle/automatic`` to construct this style.
public struct POAutomaticLabeledContentStyle: POLabeledContentStyle {

    /// Creates an automatic labeled content style.
    public init(primaryTextStyle: POTextStyle, secondaryTextStyle: POTextStyle) {
        self.primaryTextStyle = primaryTextStyle
        self.secondaryTextStyle = secondaryTextStyle
    }

    // MARK: - POLabeledContentStyle

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: POSpacing.space8) {
            Group(poSubviews: configuration.label) { children in
                VStack(alignment: .leading, spacing: POSpacing.space6) {
                    if let first = children.first {
                        first.textStyle(primaryTextStyle)
                    }
                    ForEach(children.dropFirst()) { child in
                        child.textStyle(secondaryTextStyle)
                    }
                }
            }
            Spacer()
            configuration.content
        }
    }

    // MARK: - Private Properties

    private let primaryTextStyle: POTextStyle, secondaryTextStyle: POTextStyle
}

@available(iOS 16, *)
#Preview {
    POLabeledContent {
        Button { } label: {
            Label {
                Text("Copy")
            } icon: {
                Image(poResource: .info)
                    .renderingMode(.template)
            }
        }
        .buttonStyle(.secondary)
        .controlSize(.small)
        .controlWidth(.regular)
    } label: {
        Text("Account number")
        Text("4242 4242 4242 4242")
    }
    .padding()
}
