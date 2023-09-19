//
//  PONativeAlternativePaymentMethodStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.11.2022.
//

import UIKit

/// Defines style for native alternative payment method module.
public struct PONativeAlternativePaymentMethodStyle {

    /// Title style.
    public let title: POTextStyle

    /// Section title text style.
    public let sectionTitle: POTextStyle

    /// Input style.
    public let input: POInputStyle

    /// Input style.
    public let codeInput: POInputStyle

    /// Radio button style.
    public let radioButton: PORadioButtonStyle

    /// Error description text style.
    public let errorDescription: POTextStyle

    /// Actions style.
    public let actions: POActionsContainerStyle

    /// Activity indicator style. Please note that maximum height of activity indicator
    /// is limited to 256.
    public let activityIndicator: POActivityIndicatorStyle

    /// Message style.
    ///
    /// - NOTE: This style may be used to render rich attributed text so please make sure that your font's
    /// typeface supports different variations. Currently framework may use bold, italic and mono space traits.
    public let message: POTextStyle

    /// Success message style.
    public let successMessage: POTextStyle

    /// Background style.
    public let background: PONativeAlternativePaymentMethodBackgroundStyle

    /// Separator color.
    public let separatorColor: UIColor

    public init(
        title: POTextStyle? = nil,
        sectionTitle: POTextStyle? = nil,
        input: POInputStyle? = nil,
        codeInput: POInputStyle? = nil,
        radioButton: PORadioButtonStyle? = nil,
        errorDescription: POTextStyle? = nil,
        actions: POActionsContainerStyle? = nil,
        activityIndicator: POActivityIndicatorStyle? = nil,
        message: POTextStyle? = nil,
        successMessage: POTextStyle? = nil,
        background: PONativeAlternativePaymentMethodBackgroundStyle? = nil,
        separatorColor: UIColor? = nil
    ) {
        self.title = title ?? Constants.title
        self.sectionTitle = sectionTitle ?? Constants.sectionTitle
        self.input = input ?? Constants.input
        self.codeInput = codeInput ?? Constants.codeInput
        self.radioButton = radioButton ?? Constants.radioButton
        self.errorDescription = errorDescription ?? Constants.errorDescription
        self.actions = actions ?? Constants.actions
        self.activityIndicator = activityIndicator ?? Constants.activityIndicator
        self.message = message ?? Constants.message
        self.successMessage = successMessage ?? Constants.successMessage
        self.background = background ?? Constants.background
        self.separatorColor = separatorColor ?? Constants.separatorColor
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let title = POTextStyle(color: UIColor(resource: .Text.primary), typography: .Medium.title)
        static let sectionTitle = POTextStyle(
            color: UIColor(resource: .Text.secondary), typography: .Fixed.labelHeading
        )
        static let input = POInputStyle.default()
        static let codeInput = POInputStyle.default(typography: .Medium.title)
        static let radioButton = PORadioButtonStyle.default
        static let errorDescription = POTextStyle(color: UIColor(resource: .Text.error), typography: .Fixed.label)
        static let actions = POActionsContainerStyle()
        static let activityIndicator = POActivityIndicatorStyle.system(
            .whiteLarge, color: UIColor(resource: .Text.secondary)
        )
        static let message = POTextStyle(color: UIColor(resource: .Text.primary), typography: .Fixed.body)
        static let successMessage = POTextStyle(color: UIColor(resource: .Text.success), typography: .Fixed.body)
        static let background = PONativeAlternativePaymentMethodBackgroundStyle()
        static let separatorColor = UIColor(resource: .Border.subtle)
    }
}
