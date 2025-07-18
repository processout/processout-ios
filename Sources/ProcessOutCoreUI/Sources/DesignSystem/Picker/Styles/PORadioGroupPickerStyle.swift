//
//  PORadioGroupPickerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.10.2023.
//

import SwiftUI

@_spi(PO)
public struct PORadioGroupPickerStyle<RadioButtonStyle: ButtonStyle>: POPickerStyle {

    public init(radioButtonStyle: RadioButtonStyle = PORadioButtonStyle.radio, inputStyle: POInputStyle = .large) {
        self.radioButtonStyle = radioButtonStyle
        self.inputStyle = inputStyle
    }

    public func makeBody(configuration: POPickerStyleConfiguration) -> some View {
        ContentView(configuration: configuration)
            .buttonStyle(radioButtonStyle)
            .inputStyle(inputStyle)
    }

    // MARK: - Private Properties

    private let radioButtonStyle: RadioButtonStyle
    private let inputStyle: POInputStyle
}

@MainActor
private struct ContentView: View {

    let configuration: POPickerStyleConfiguration

    // MARK: - View

    var body: some View {
        let resolvedInputStyle = inputStyle.resolve(isInvalid: isControlInvalid, isFocused: false)
        VStack(alignment: .leading, spacing: 0) {
            configuration.prompt
                .textStyle(resolvedInputStyle.label)
                .padding(.vertical, POSpacing.space12)
            VStack(alignment: .leading, spacing: POSpacing.space2) {
                Group(poSubviews: configuration.content) { children in
                    ForEach(children) { child in
                        Button {
                            configuration.selection = child.id
                        } label: {
                            child
                        }
                        .contentShape(.rect)
                        .controlSelected(child.id == configuration.selection)
                    }
                }
            }
            .compositingGroup()
            .padding(POSpacing.space4)
            .border(style: resolvedInputStyle.border)
        }
        .animation(.default, value: isControlInvalid)
    }

    // MARK: - Private Properties

    @Environment(\.inputStyle)
    private var inputStyle

    @Environment(\.isControlInvalid)
    private var isControlInvalid
}

extension POPickerStyle where Self == PORadioGroupPickerStyle<PORadioButtonStyle> {

    /// A picker style that presents the options as a group of radio buttons.
    public static var radioGroup: PORadioGroupPickerStyle<PORadioButtonStyle> {
        PORadioGroupPickerStyle()
    }
}

@available(iOS 17, *)
#Preview {
    @Previewable @State var value: String?
    POPicker(selection: $value) {
        Text("Hello").id("1")
        Text("World").id("2")
    } prompt: {
        Text("Placeholder")
    }
    .pickerStyle(.radioGroup as PORadioGroupPickerStyle)
    .padding()
    .controlInvalid(true)
}
