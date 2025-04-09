//
//  PORadioGroupPickerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.10.2023.
//

import SwiftUI

/// A picker style that presents the options as a group of radio buttons.
@available(iOS 14, *)
public struct PORadioGroupPickerStyle<RadioButtonStyle: ButtonStyle>: POPickerStyle {

    public init(radioButtonStyle: RadioButtonStyle = PORadioButtonStyle.radio) {
        self.radioButtonStyle = radioButtonStyle
    }

    // MARK: - POPickerStyle

    public func makeBody(configuration: POPickerStyleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Group(poSubviews: configuration.content) { children in
                ForEach(children) { child in
                    Button {
                        configuration.selection = child.id
                    } label: {
                        child
                    }
                    .padding(.vertical, POSpacing.extraSmall)
                    .frame(minHeight: Constants.minHeight)
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
    static let minHeight: CGFloat = 44
}
