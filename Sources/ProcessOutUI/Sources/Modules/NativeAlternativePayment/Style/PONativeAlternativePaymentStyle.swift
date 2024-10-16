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
    public let sectionTitle: POTextStyle

    /// Input style.
    public let input: POInputStyle

    /// Input style.
    public let codeInput: POInputStyle

    /// Radio button style.
    public let radioButton: any ButtonStyle

    /// Error description text style.
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
    public let successMessage: POTextStyle

    /// Background style.
    public let background: PONativeAlternativePaymentBackgroundStyle

    /// Separator color.
    public let separatorColor: Color

    public init(
        title: POTextStyle,
        sectionTitle: POTextStyle,
        input: POInputStyle,
        codeInput: POInputStyle,
        radioButton: some ButtonStyle,
        errorDescription: POTextStyle,
        actionsContainer: POActionsContainerStyle,
        progressView: some ProgressViewStyle,
        message: POTextStyle,
        successMessage: POTextStyle,
        background: PONativeAlternativePaymentBackgroundStyle,
        separatorColor: Color
    ) {
        self.title = title
        self.sectionTitle = sectionTitle
        self.input = input
        self.codeInput = codeInput
        self.radioButton = radioButton
        self.errorDescription = errorDescription
        self.actionsContainer = actionsContainer
        self.progressView = progressView
        self.message = message
        self.successMessage = successMessage
        self.background = background
        self.separatorColor = separatorColor
    }
}

@available(iOS 14, *)
extension PONativeAlternativePaymentStyle {

    /// Default native alternative payment style.
    public static let `default` = PONativeAlternativePaymentStyle(
        title: POTextStyle(color: Color(poResource: .Text.primary), typography: .title),
        sectionTitle: POTextStyle(color: Color(poResource: .Text.primary), typography: .label1),
        input: .medium,
        codeInput: .large,
        radioButton: .radio,
        errorDescription: POTextStyle(color: Color(poResource: .Text.error), typography: .label2),
        actionsContainer: .default,
        progressView: .circular,
        message: POTextStyle(color: Color(poResource: .Text.primary), typography: .body1),
        successMessage: POTextStyle(color: Color(poResource: .Text.success), typography: .body1),
        background: .default,
        separatorColor: Color(poResource: .Border.subtle)
    )
}
