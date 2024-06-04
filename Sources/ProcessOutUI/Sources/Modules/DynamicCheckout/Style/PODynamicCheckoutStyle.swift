//
//  PODynamicCheckoutStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.02.2024.
//

import PassKit
import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Defines style for dynamic checkout view.
///
/// For more information about styling specific components, see
/// [the dedicated documentation.](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutcoreui)
@available(iOS 14, *)
public struct PODynamicCheckoutStyle {

    public struct Section {

        /// Section border style.
        public let border: POBorderStyle

        /// Creates section style instance.
        public init(border: POBorderStyle) {
            self.border = border
        }
    }

    public struct Subsection {

        /// Title style.
        public let title: POTextStyle

        /// Information text style.
        public let informationText: POTextStyle

        /// Divider color.
        public let dividerColor: Color

        public init(title: POTextStyle, informationText: POTextStyle, dividerColor: Color) {
            self.title = title
            self.informationText = informationText
            self.dividerColor = dividerColor
        }
    }

    public struct Success {

        /// Success message style.
        public let message: POTextStyle

        /// Success background style.
        public let backgroundColor: Color

        /// Creates style instance.
        public init(message: POTextStyle, backgroundColor: Color) {
            self.message = message
            self.backgroundColor = backgroundColor
        }
    }

    /// Section style.
    public let section: Section

    /// Payment options are organized in subsections within same section.
    public let subsection: Subsection

    /// Progress view style.
    public let progressView: any ProgressViewStyle

    /// Input title text style.
    public let inputTitle: POTextStyle

    /// Input style.
    public let input: POInputStyle

    /// Input style.
    public let codeInput: POInputStyle

    /// Radio button style.
    public let radioButton: any ButtonStyle

    /// Error description text style.
    public let errorText: POTextStyle

    /// PassKit payment button style.
    public let passKitPaymentButtonStyle: POPassKitPaymentButtonStyle

    /// Generic express payment button style. When default style is used,
    /// equals to `POBrandButtonStyle.brand`.
    public let expressPaymentButtonStyle: any ButtonStyle

    /// Informational message style.
    public let message: any POMessageViewStyle

    /// Background color.
    public let backgroundColor: Color

    /// Success style.
    public let success: Success

    /// Actions container style.
    public let actionsContainer: POActionsContainerStyle

    /// Creates dynamic checkout style.
    public init(
        section: PODynamicCheckoutStyle.Section,
        subsection: PODynamicCheckoutStyle.Subsection,
        progressView: some ProgressViewStyle,
        inputTitle: POTextStyle,
        input: POInputStyle,
        codeInput: POInputStyle,
        radioButton: some ButtonStyle,
        errorText: POTextStyle,
        passKitPaymentButtonStyle: POPassKitPaymentButtonStyle,
        expressPaymentButtonStyle: some ButtonStyle,
        message: some POMessageViewStyle,
        backgroundColor: Color,
        success: Success,
        actionsContainer: POActionsContainerStyle
    ) {
        self.section = section
        self.subsection = subsection
        self.progressView = progressView
        self.inputTitle = inputTitle
        self.input = input
        self.codeInput = codeInput
        self.radioButton = radioButton
        self.errorText = errorText
        self.passKitPaymentButtonStyle = passKitPaymentButtonStyle
        self.expressPaymentButtonStyle = expressPaymentButtonStyle
        self.message = message
        self.backgroundColor = backgroundColor
        self.success = success
        self.actionsContainer = actionsContainer
    }
}
