//
//  CodeFieldViewCoordinator.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2024.
//

import Foundation

final class CodeFieldViewCoordinator {

    var representable: CodeFieldRepresentable! // swiftlint:disable:this implicitly_unwrapped_optional

    // MARK: -

    var text: String {
        representable.text
    }

    var hasText: Bool {
        !text.isEmpty
    }

    func insertText(_ text: String) {
        if let character = text.last, character.isNewline {
            representable.textIndex = nil
            return
        }
        let insertionIndex: String.Index
        if text.count == representable.length {
            insertionIndex = representable.text.startIndex
        } else if let index = representable.textIndex, text.indices.contains(index) {
            insertionIndex = index
        } else {
            insertionIndex = representable.text.endIndex
        }
        var newText = representable.$text.wrappedValue
        newText.insert(contentsOf: text, at: insertionIndex)
        newText = String(newText.prefix(representable.length))
        let newIndex = newText.index(insertionIndex, offsetBy: text.count, limitedBy: newText.endIndex)
        representable.text = newText
        representable.textIndex = newIndex ?? newText.endIndex
        representable.isMenuVisible = false
    }

    func deleteBackward() {
        guard let currentIndex = representable.textIndex, currentIndex != representable.text.startIndex else {
            return
        }
        let index = representable.text.index(before: currentIndex)
        representable.text.remove(at: index)
        representable.textIndex = index
        representable.isMenuVisible = false
    }

    // MARK: - Editing

    func didBeginEditing() {
        RunLoop.main.perform {
            if self.representable.textIndex == nil {
                self.representable.textIndex = self.representable.text.endIndex
            }
        }
    }

    func didEndEditing() {
        RunLoop.main.perform {
            self.representable.textIndex = nil
            self.representable.isMenuVisible = false
        }
    }
}
