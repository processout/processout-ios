//
//  PORadioGroupPickerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.10.2023.
//

import SwiftUI

public struct PORadioGroupPickerStyle<RadioButtonStyle: ButtonStyle>: POPickerStyle {

    init(radioButtonStyle: RadioButtonStyle = PORadioButtonStyle.radio) {
        self.radioButtonStyle = radioButtonStyle
    }

    public func makeBody(configuration: POPickerStyleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(configuration.elements) { element in
                Button(action: element.select, label: element.makeBody)
                    .radioButtonSelected(element.isSelected)
            }
        }
        .buttonStyle(radioButtonStyle)
    }

    // MARK: - Private Properties

    private let radioButtonStyle: RadioButtonStyle
}

extension POPickerStyle where Self == PORadioGroupPickerStyle<PORadioButtonStyle> {

    /// A picker style that presents the options as a group of radio buttons.
    public static var radioGroup: PORadioGroupPickerStyle<PORadioButtonStyle> {
        PORadioGroupPickerStyle()
    }
}
