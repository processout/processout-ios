//
//  PONativeAlternativePaymentStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Defines style for native alternative payment module.
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
    public let groupBoxStyle: any GroupBoxStyle

    /// Labeled content style. Primarily used with customer instructions.
    public let labeledContentStyle: any POLabeledContentStyle

    // MARK: - Buttons

    /// Actions container style.
    public let actionsContainer: POActionsContainerStyle

    // MARK: - Progress

    /// Progress view style to use when screen loads initial content.
    public let progressView: any ProgressViewStyle

    /// Payment confirmation progress view style.
    public let paymentConfirmationProgressView: any PONativeAlternativePaymentConfirmationProgressViewStyle

    // MARK: - Misc

    /// Title style.
    public let title: POTextStyle

    /// Message view style, that adopts itself depending on severity.
    public let messageView: any POMessageViewStyle

    /// Payment success view style.
    public let successView: any PONativeAlternativePaymentSuccessViewStyle

    /// Background color.
    public let backgroundColor: Color

    /// Separator color.
    public let separatorColor: Color

    public init(
        input: POInputStyle,
        largeInput: POInputStyle,
        radioButton: any ButtonStyle,
        toggle: any ToggleStyle,
        bodyText: POTextStyle,
        groupBoxStyle: any GroupBoxStyle,
        labeledContentStyle: any POLabeledContentStyle,
        actionsContainer: POActionsContainerStyle,
        progressView: any ProgressViewStyle,
        paymentConfirmationProgressView: any PONativeAlternativePaymentConfirmationProgressViewStyle,
        title: POTextStyle,
        messageView: any POMessageViewStyle,
        successView: any PONativeAlternativePaymentSuccessViewStyle,
        backgroundColor: Color,
        separatorColor: Color
    ) {
        self.input = input
        self.largeInput = largeInput
        self.radioButton = radioButton
        self.toggle = toggle
        self.bodyText = bodyText
        self.groupBoxStyle = groupBoxStyle
        self.labeledContentStyle = labeledContentStyle
        self.actionsContainer = actionsContainer
        self.progressView = progressView
        self.paymentConfirmationProgressView = paymentConfirmationProgressView
        self.title = title
        self.messageView = messageView
        self.successView = successView
        self.backgroundColor = backgroundColor
        self.separatorColor = separatorColor
    }
}

extension PONativeAlternativePaymentStyle {

    /// Default native alternative payment style.
    public static let `default` = PONativeAlternativePaymentStyle(
        input: .medium,
        largeInput: .large,
        radioButton: .radio,
        toggle: .poCheckbox,
        bodyText: .init(
            color: .Text.primary, typography: .Paragraph.s16(weight: .medium)
        ),
        groupBoxStyle: .poAutomatic,
        labeledContentStyle: .automatic,
        actionsContainer: .default,
        progressView: .circular,
        paymentConfirmationProgressView: .automatic,
        title: .init(
            color: .Text.primary, typography: .Text.s20(weight: .medium)
        ),
        messageView: .toast,
        successView: .automatic,
        backgroundColor: .Surface.primary,
        separatorColor: .Border.primary
    )
}

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
}

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
        self.input = input
        self.largeInput = codeInput
        self.radioButton = radioButton
        self.toggle = toggle
        self.bodyText = message
        self.groupBoxStyle = .poAutomatic
        self.labeledContentStyle = .automatic
        self.actionsContainer = actionsContainer
        self.progressView = progressView
        self.paymentConfirmationProgressView = .automatic
        self.title = title
        self.messageView = .toast
        self.successView = .automatic
        self.backgroundColor = background.regular
        self.separatorColor = separatorColor
    }
}
