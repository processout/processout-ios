//
//  POCardUpdateStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Defines style for card update view.
///
/// For more information about styling specific components, see
/// [the dedicated documentation.](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutcoreui)
@MainActor
@preconcurrency
public struct POCardUpdateStyle {

    /// Title style.
    public let title: POTextStyle

    /// Section title text style.
    public let sectionTitle: POTextStyle

    /// Input style.
    public let input: POInputStyle

    /// Radio button style.
    public let radioButton: any ButtonStyle

    /// Error description text style.
    public let errorDescription: POTextStyle

    /// Background color.
    public let backgroundColor: Color

    /// Actions container style.
    public let actionsContainer: POActionsContainerStyle

    /// Progress view style.
    public let progressView: any ProgressViewStyle

    /// Separator color.
    public let separatorColor: Color

    public init(
        title: POTextStyle,
        sectionTitle: POTextStyle? = nil,
        input: POInputStyle,
        radioButton: (any ButtonStyle)? = nil,
        errorDescription: POTextStyle,
        backgroundColor: Color,
        actionsContainer: POActionsContainerStyle,
        progress: some ProgressViewStyle,
        separatorColor: Color
    ) {
        self.title = title
        self.sectionTitle = sectionTitle
            ?? POTextStyle(color: .Input.Text.default, typography: .Text.s14(weight: .medium))
        self.input = input
        self.radioButton = radioButton ?? .radio
        self.errorDescription = errorDescription
        self.backgroundColor = backgroundColor
        self.actionsContainer = actionsContainer
        self.progressView = progress
        self.separatorColor = separatorColor
    }
}

extension POCardUpdateStyle {

    /// Default card update style.
    public static var `default`: POCardUpdateStyle {
        POCardUpdateStyle(
            title: POTextStyle(color: Color.Text.primary, typography: .Text.s20(weight: .medium)),
            input: .medium,
            errorDescription: POTextStyle(color: Color.Input.Text.error, typography: .Text.s12(weight: .regular)),
            backgroundColor: Color.Surface.primary,
            actionsContainer: .default,
            progress: .circular,
            separatorColor: Color.Border.primary
        )
    }
}
