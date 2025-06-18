//
//  BorderedCodeFieldStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2024.
//

import SwiftUI

@available(iOS 14, *)
struct DefaultCodeFieldStyle: CodeFieldStyle {

    func makeBody(configuration: Configuration) -> some View {
        let paddedText = self.paddedText(configuration: configuration)
        HStack(spacing: POSpacing.space8) {
            ForEach(Array(paddedText.indices), id: \.self) { index in
                DefaultCodeFieldStyleCharacterView(
                    value: paddedText[index],
                    caretAlignment: caretAlignment(forCharacterAt: index, configuration: configuration)
                )
            }
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let pad = "\u{2007}" // Figure (numeric) space
    }

    // MARK: - Private Methods

    private func paddedText(configuration: Configuration) -> String {
        configuration.text.padding(toLength: configuration.length, withPad: Constants.pad, startingAt: 0)
    }

    private func caretAlignment(
        forCharacterAt index: String.Index, configuration: Configuration
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
