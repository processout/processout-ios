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
            Group(poSubviews: configuration.content) { children in
                ForEach(children) { child in
                    Button {
                        configuration.selection = child.id
                    } label: {
                        child
                    }
                    .padding(.vertical, Constants.verticalPadding)
                    .contentShape(.rect)
                    .controlSelected(child.id == configuration.selection)
                }
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
