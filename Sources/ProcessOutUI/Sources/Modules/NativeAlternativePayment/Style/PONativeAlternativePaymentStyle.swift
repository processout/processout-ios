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

    // MARK: - Parameters

    /// Input style.
    public let input: POInputStyle

    /// Large input style. Used with code fields and to style inline picker label.
    public let largeInput: POInputStyle

    /// Radio button style.
    public let radioButton: any ButtonStyle

    /// Toggle style.
    public let toggle: any ToggleStyle

    // MARK: - Customer Instructions

    /// Main content text style. One of possible use cases is to style instruction user needs to follow in
    /// order to complete payment.
    public let bodyText: POTextStyle

    /// Group box main purpose is to group multiple customer instructions.
    public let groupBoxStyle: any GroupBoxStyle = .poAutomatic

    /// Labeled content style. Primarily used with customer instructions.
    public let labeledContentStyle: any POLabeledContentStyle = .automatic

    // MARK: - Buttons

    /// Style for primary button.
    public let primaryButton: any ButtonStyle

    /// Style for secondary button.
    public let secondaryButton: any ButtonStyle

    // MARK: - Progress

    /// Progress view style to use when screen loads initial content.
    public let progressView: any ProgressViewStyle

    /// Payment confirmation progress view style.
    public let paymentConfirmationProgressView: any PONativeAlternativePaymentConfirmationProgressViewStyle = .automatic

    // MARK: - Misc

    /// Title style.
    public let title: POTextStyle

    /// Message view style, that adopts itself depending on severity.
    public let messageView: any POMessageViewStyle = .toast

    /// Payment success view style.
    public let successView: any PONativeAlternativePaymentSuccessViewStyle = .automatic

    /// Background color.
    public let backgroundColor: Color

    /// Separator color.
    public let separatorColor: Color
}

@available(iOS 14, *)
extension PONativeAlternativePaymentStyle {

    /// Default native alternative payment style.
    public static let `default` = PONativeAlternativePaymentStyle(
        title: POTextStyle(color: .Text.primary, typography: .Text.s20(weight: .medium)),
        sectionTitle: POTextStyle(color: .Input.Text.default, typography: .Text.s14(weight: .medium)),
        input: .medium,
        codeInput: .large,
        radioButton: .radio,
        errorDescription: POTextStyle(color: .Input.Text.error, typography: .Text.s12(weight: .regular)),
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

@available(iOS 14, *)
extension PONativeAlternativePaymentStyle {

    /// Input style.
    @available(*, deprecated)
    public var codeInput: POInputStyle {
        largeInput
    }

    /// Section title text style.
    @available(*, deprecated)
    public var sectionTitle: POTextStyle {
        POTextStyle(color: .Input.Text.default, typography: .Text.s14(weight: .medium))
    }

    /// Error description text style.
    @available(*, deprecated, message: "Not used.")
    public var errorDescription: POTextStyle {
        POTextStyle(color: .Input.Text.error, typography: .Text.s12(weight: .regular))
    }

    /// Message style.
    ///
    /// - NOTE: This style may be used to render rich attributed text so please make sure that your font's
    /// typeface supports different variations. Currently framework may use bold, italic and mono space traits.
    @available(*, deprecated, renamed: "bodyText")
    public var message: POTextStyle {
        bodyText
    }

    /// Success message style.
    @available(*, deprecated, message: "Not used.")
    public var successMessage: POTextStyle {
        POTextStyle(color: .Text.positive, typography: .Paragraph.s16(weight: .medium))
    }

    /// Background style.
    @available(*, deprecated, message: "Set background color directly.")
    public var background: PONativeAlternativePaymentBackgroundStyle {
        .default
    }

    /// Actions container style.
    @available(*, deprecated, message: "Set primary and secondary button styles directly.")
    public var actionsContainer: POActionsContainerStyle {
        .default
    }
}

@available(iOS 14, *)
extension PONativeAlternativePaymentStyle {

    @available(*, deprecated)
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
        background: PONativeAlternativePaymentBackgroundStyle,
        separatorColor: Color
    ) {
        self.title = title
        self.input = input
        self.largeInput = codeInput
        self.radioButton = radioButton
        self.toggle = toggle
        self.primaryButton = actionsContainer.primary
        self.secondaryButton = actionsContainer.secondary
        self.progressView = progressView
        self.bodyText = message
        self.backgroundColor = background.regular
        self.separatorColor = separatorColor
    }
}
