//
//  PORadioGroupPickerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.10.2023.
//

import SwiftUI

@_spi(PO)
@available(iOS 14, *)
public struct PORadioGroupPickerStyle<RadioButtonStyle: ButtonStyle>: POPickerStyle {

    public init(radioButtonStyle: RadioButtonStyle = PORadioButtonStyle.radio) {
        self.radioButtonStyle = radioButtonStyle
    }

    public func makeBody(configuration: POPickerStyleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: POSpacing.extraExtraSmall) {
            ForEach(configuration.elements) { element in
                Button(action: element.select, label: element.makeBody)
                    .padding(.vertical, Constants.verticalPadding)
                    .contentShape(.rect)
                    .controlSelected(element.isSelected)
            }
        }
        .buttonStyle(radioButtonStyle)
    }

    // MARK: - Private Properties

    private let radioButtonStyle: RadioButtonStyle
}

@available(iOS 14, *)
extension POPickerStyle where Self == PORadioGroupPickerStyle<PORadioButtonStyle> {

    /// A picker style that presents the options as a group of radio buttons.
    public static var radioGroup: PORadioGroupPickerStyle<PORadioButtonStyle> {
        PORadioGroupPickerStyle()
    }
}

private enum Constants {
    static let verticalPadding: CGFloat = 11
}
