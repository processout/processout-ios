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
        let text = paddedText(configuration: configuration)
        HStack(spacing: POSpacing.extraSmall) {
            ForEach(Array(text.indices), id: \.self) { index in
                let caretPosition = caretPosition(at: index, configuration: configuration)
                DefaultCodeFieldStyleCharacterView(value: text[index], caretPosition: caretPosition) { position in
                    set(index: index, at: position, configuration: configuration)
                }
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

    private func set(
        index: String.Index,
        at position: DefaultCodeFieldStyleCharacterView.CaretPosition,
        configuration: Configuration
    ) {
        var newIndex = index
        if position == .after, index < configuration.text.endIndex {
            newIndex = configuration.text.index(after: newIndex)
        }
        if configuration.text.indices.contains(newIndex) {
            configuration.setIndex(newIndex)
        } else {
            configuration.setIndex(configuration.text.endIndex)
        }
    }

    private func caretPosition(
        at index: String.Index, configuration: Configuration
    ) -> DefaultCodeFieldStyleCharacterView.CaretPosition? {
        guard let selectedIndex = configuration.index else {
            return nil
        }
        if index == selectedIndex {
            return .before
        }
        // swiftlint:disable:next line_length
        if index == configuration.text.indices.last, selectedIndex == configuration.text.endIndex, configuration.text.count == configuration.length {
            return .after
        }
        return nil
    }
}
