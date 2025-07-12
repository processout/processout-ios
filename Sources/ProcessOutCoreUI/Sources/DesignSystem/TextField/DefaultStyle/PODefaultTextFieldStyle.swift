//
//  PODefaultTextFieldStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.01.2025.
//

import SwiftUI

/// The default text field style that resolves its appearance based on current input style.
@_spi(PO)
@available(iOS 14, *)
public struct PODefaultTextFieldStyle: POTextFieldStyle {

    public func makeBody(configuration: Configuration) -> some View {
        DefaultTextFieldStyleContentView(configuration: configuration)
    }
}

@available(iOS 14, *)
private struct DefaultTextFieldStyleContentView: View {

    let configuration: POTextFieldStyleConfiguration

    // MARK: - View

    var body: some View {
        let resolvedStyle = inputStyle.resolve(isInvalid: isInvalid, isFocused: configuration.isEditing)
        HStack {
            FloatingValue(isFloating: !configuration.text.isEmpty, spacing: POSpacing.space2) {
                configuration.textField
                    .textStyle(resolvedStyle.text)
            } valueSizingView: {
                Text(" ")
                    .typography(resolvedStyle.text.typography)
            } placeholder: { isFloating in
                configuration.prompt
                    .lineLimit(1)
                    .textStyle(resolvedStyle.label.scaledBy(isFloating ? 0.8 : 1))
                    .allowsHitTesting(false)
            }
            configuration.trailingView
                .foregroundColor(
                    configuration.text.isEmpty ? resolvedStyle.label.color : resolvedStyle.text.color
                )
        }
        .padding(Constants.padding)
        .frame(maxWidth: .infinity, minHeight: Constants.minHeight)
        .background(resolvedStyle.backgroundColor)
        .border(style: resolvedStyle.border)
        .shadow(style: resolvedStyle.shadow)
        .accentColor(resolvedStyle.tintColor)
        .animation(.default, value: isInvalid)
        .backport.geometryGroup()
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let padding = EdgeInsets(
            top: POSpacing.space6, leading: POSpacing.space12, bottom: POSpacing.space6, trailing: POSpacing.space16
        )
        static let minHeight: CGFloat = 52
    }

    // MARK: - Private Properties

    @Environment(\.inputStyle)
    private var inputStyle

    @Environment(\.isControlInvalid)
    private var isInvalid
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var text = ""
    POTextField(text: $text, prompt: "Placeholder")
        .padding()
}
