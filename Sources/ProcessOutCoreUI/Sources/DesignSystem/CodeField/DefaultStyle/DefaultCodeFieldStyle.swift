//
//  BorderedCodeFieldStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2024.
//

import SwiftUI

struct DefaultCodeFieldStyle: CodeFieldStyle {

    func makeBody(configuration: Configuration) -> some View {
        ContentView(configuration: configuration)
    }
}

private struct ContentView: View {

    let configuration: CodeFieldStyle.Configuration

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            configuration.label
                .textStyle(
                    style.resolve(isInvalid: isInvalid, isFocused: configuration.isEditing).label
                )
                .padding(.vertical, POSpacing.space12)
            HStack(spacing: POSpacing.space8) {
                let paddedText = self.paddedText()
                ForEach(Array(paddedText.indices), id: \.self) { index in
                    DefaultCodeFieldStyleCharacterView(
                        value: paddedText[index],
                        caretAlignment: caretAlignment(forCharacterAt: index)
                    )
                }
            }
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let pad = "\u{2007}" // Figure (numeric) space
    }

    // MARK: - Private Properties

    @Environment(\.inputStyle)
    private var style

    @Environment(\.isControlInvalid)
    private var isInvalid

    // MARK: - Private Methods

    private func paddedText() -> String {
        configuration.text.padding(toLength: configuration.length, withPad: Constants.pad, startingAt: 0)
    }

    private func caretAlignment(
        forCharacterAt index: String.Index
    ) -> Binding<DefaultCodeFieldStyleCharacterView.CaretAlignment?> {
        let binding = Binding<DefaultCodeFieldStyleCharacterView.CaretAlignment?> {
            guard let insertionPoint = configuration.insertionPoint, configuration.isEditing else {
                return nil
            }
            if index == insertionPoint {
                return .leading
            }
            if index == configuration.text.indices.last,
               insertionPoint == configuration.text.endIndex,
               configuration.text.count == configuration.length {
                return .trailing
            }
            return nil
        } set: { newAlignment in
            var newInsertionPoint = index
            if newAlignment == .trailing, index < configuration.text.endIndex {
                newInsertionPoint = configuration.text.index(after: newInsertionPoint)
            }
            if configuration.text.indices.contains(newInsertionPoint) {
                configuration.insertionPoint = newInsertionPoint
            } else {
                configuration.insertionPoint = configuration.text.endIndex
            }
        }
        return binding
    }
}

@available(iOS 17, *)
#Preview {
    @Previewable @State var text = ""
    POCodeField(text: $text, length: 6)
        .inputStyle(.large)
}
