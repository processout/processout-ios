//
//  PONativeAlternativePaymentStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Defines style for native alternative payment module.
@available(iOS 14, *)
@MainActor
@preconcurrency
public struct PONativeAlternativePaymentStyle {

    /// Title style.
    public let title: POTextStyle

    /// Section title text style.
    @available(*, deprecated)
    public let sectionTitle: POTextStyle

    /// Input style.
    public let input: POInputStyle

    /// Input style.
    public let codeInput: POInputStyle

    /// Radio button style.
    public let radioButton: any ButtonStyle

    /// Toggle style.
    public let toggle: any ToggleStyle

    /// Error description text style.
    @available(*, deprecated)
    public let errorDescription: POTextStyle

    /// Actions container style.
    public let actionsContainer: POActionsContainerStyle

    /// Progress view style.
    public let progressView: any ProgressViewStyle

    /// Message style.
    ///
    /// - NOTE: This style may be used to render rich attributed text so please make sure that your font's
    /// typeface supports different variations. Currently framework may use bold, italic and mono space traits.
    public let message: POTextStyle

    /// Success message style.
    @available(*, deprecated)
    public let successMessage: POTextStyle

    /// Background color.
    public let backgroundColor: Color

    /// Background style.
    @available(*, deprecated, message: "Set background color instead.")
    public let background: PONativeAlternativePaymentBackgroundStyle

    /// Separator color.
    public let separatorColor: Color

    public init(
        title: POTextStyle,
        sectionTitle: POTextStyle,
        input: POInputStyle,
        codeInput: POInputStyle,
        radioButton: some ButtonStyle,
        toggle: some ToggleStyle = .poCheckbox,
        errorDescription: POTextStyle,
        actionsContainer: POActionsContainerStyle,
        progressView: some ProgressViewStyle,
        message: POTextStyle,
        successMessage: POTextStyle,
        backgroundColor: Color? = nil,
        background: PONativeAlternativePaymentBackgroundStyle,
        separatorColor: Color
    ) {
        self.title = title
        self.sectionTitle = sectionTitle
        self.input = input
        self.codeInput = codeInput
        self.radioButton = radioButton
        self.toggle = toggle
        self.errorDescription = errorDescription
        self.actionsContainer = actionsContainer
        self.progressView = progressView
        self.message = message
        self.successMessage = successMessage
        self.backgroundColor = backgroundColor ?? .Surface.primary
        self.background = background
        self.separatorColor = separatorColor
    }
}

@available(iOS 14, *)
extension PONativeAlternativePaymentStyle {

    /// Default native alternative payment style.
    public static let `default` = PONativeAlternativePaymentStyle(
        title: POTextStyle(color: .Text.primary, typography: .Text.s20(weight: .medium)),
        sectionTitle: POTextStyle(color: .Input.Label.default, typography: .Text.s14(weight: .medium)),
        input: .medium,
        codeInput: .large,
        radioButton: .radio,
        errorDescription: POTextStyle(color: .Input.Label.error, typography: .Text.s12(weight: .regular)),
        actionsContainer: .default,
        progressView: .circular,
        message: POTextStyle(color: .Text.primary, typography: .Paragraph.s16(weight: .medium)),
        successMessage: POTextStyle(
            color: .Text.positive, typography: .Paragraph.s16(weight: .medium)
        ),
        background: .default,
        separatorColor: .Border.primary
    )
}
