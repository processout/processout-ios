//
//  PODynamicCheckoutStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.02.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Defines style for dynamic checkout view.
///
/// For more information about styling specific components, see
/// [the dedicated documentation.](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutcoreui)
@available(iOS 14, *)
public struct PODynamicCheckoutStyle {

    public struct Section {

        /// Section title style.
        public let title: POTextStyle

        /// Section border style.
        public let border: POBorderStyle

        /// Style to apply to divider sepparating different sections.
        public var divider: POLabeledDividerStyle

        /// Creates section style instance.
        public init(title: POTextStyle, border: POBorderStyle, divider: POLabeledDividerStyle) {
            self.title = title
            self.border = border
            self.divider = divider
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

    /// Title style.
    public let title: POTextStyle // todo(andrii-vysotskyi): remove if unused

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

    /// Background color.
    public let backgroundColor: Color

    /// Actions container style.
    public let actionsContainer: POActionsContainerStyle

    /// Creates dynamic checkout style.
    public init(
        title: POTextStyle,
        section: PODynamicCheckoutStyle.Section,
        subsection: PODynamicCheckoutStyle.Subsection,
        progressView: any ProgressViewStyle,
        inputTitle: POTextStyle,
        input: POInputStyle,
        codeInput: POInputStyle,
        radioButton: any ButtonStyle,
        errorText: POTextStyle,
        backgroundColor: Color,
        actionsContainer: POActionsContainerStyle
    ) {
        self.title = title
        self.section = section
        self.subsection = subsection
        self.progressView = progressView
        self.inputTitle = inputTitle
        self.input = input
        self.codeInput = codeInput
        self.radioButton = radioButton
        self.errorText = errorText
        self.backgroundColor = backgroundColor
        self.actionsContainer = actionsContainer
    }
}
