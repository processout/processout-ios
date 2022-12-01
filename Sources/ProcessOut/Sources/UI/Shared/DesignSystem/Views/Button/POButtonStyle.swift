//
//  POButtonStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.11.2022.
//

import UIKit

public struct POButtonStyle {

    /// Style for normal state.
    public let normal: POButtonStateStyle

    /// Style for highlighted state.
    public let highlighted: POButtonStateStyle

    /// Style for disabled state.
    public let disabled: POButtonStateStyle

    /// Activity indicator style. Only used with normal state.
    public let activityIndicator: POActivityIndicatorStyle

    public init(
        normal: POButtonStateStyle,
        highlighted: POButtonStateStyle,
        disabled: POButtonStateStyle,
        activityIndicator: POActivityIndicatorStyle
    ) {
        self.normal = normal
        self.highlighted = highlighted
        self.disabled = disabled
        self.activityIndicator = activityIndicator
    }
}

extension POButtonStyle {

    /// Default style for primary button.
    public static let primary = POButtonStyle(
        normal: .init(
            title: .init(color: Asset.Colors.Text.primary.color, typography: .bodyDefault2),
            border: .clear(radius: 8),
            shadow: .clear,
            backgroundColor: Asset.Colors.Button.primary.color
        ),
        highlighted: .init(
            title: .init(color: Asset.Colors.Text.primary.color, typography: .bodyDefault2),
            border: .clear(radius: 8),
            shadow: .clear,
            backgroundColor: Asset.Colors.Button.highlighted.color
        ),
        disabled: .init(
            title: .init(color: Asset.Colors.Text.disabled.color, typography: .bodyDefault2),
            border: .clear(radius: 8),
            shadow: .clear,
            backgroundColor: Asset.Colors.Button.disabled.color
        ),
        activityIndicator: activityIndicatorStyle
    )

    private static var activityIndicatorStyle: POActivityIndicatorStyle {
        if #available(iOS 13.0, *) {
            return .system(.medium)
        }
        return .system(.white)
    }
}
