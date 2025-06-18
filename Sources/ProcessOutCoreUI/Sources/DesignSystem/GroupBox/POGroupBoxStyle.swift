//
//  POGroupBoxStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2025.
//

import SwiftUI

/// A custom `GroupBoxStyle` with configurable label text style, content background, border, and dividers.
@available(iOS 14, *)
@_spi(PO)
public struct POGroupBoxStyle: GroupBoxStyle {

    /// Defines styling for the content section of the group box.
    public struct ContentStyle {

        /// Creates a new content style.
        public init(dividerColor: Color, border: POBorderStyle, backgroundColor: Color) {
            self.dividerColor = dividerColor
            self.border = border
            self.backgroundColor = backgroundColor
        }

        /// Color of the divider between content items.
        let dividerColor: Color

        /// Border style of the content container.
        let border: POBorderStyle

        /// Background color of the content container.
        let backgroundColor: Color
    }

    /// Creates a new `POGroupBoxStyle` with label and content styling.
    public init(labelTextStyle: POTextStyle, contentStyle: ContentStyle) {
        self.labelTextStyle = labelTextStyle
        self.contentStyle = contentStyle
    }

    // MARK: - GroupBoxStyle

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            configuration.label
                .padding(.vertical, POSpacing.space12)
                .textStyle(labelTextStyle)
            Group(poSubviews: configuration.content) { children in
                VStack(spacing: POSpacing.space1) {
                    ForEach(children.dropLast()) { child in
                        child.padding(POSpacing.space12)
                        Rectangle()
                            .fill(contentStyle.dividerColor)
                            .frame(height: 1)
                    }
                    children.last.padding(POSpacing.space12)
                }
                .padding(POSpacing.space4)
            }
            .background(contentStyle.backgroundColor)
            .border(style: contentStyle.border)
        }
    }

    // MARK: - Private Properties

    private let labelTextStyle: POTextStyle
    private let contentStyle: ContentStyle
}
