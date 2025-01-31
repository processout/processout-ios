//
//  CodeFieldViewCoordinator.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2024.
//

import SwiftUI

@MainActor
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
        let insertionIndex: String.Index
        if text.count == representable.length {
            insertionIndex = self.text.startIndex
        } else if let index = representable.textIndex, self.text.indices.contains(index) {
            insertionIndex = index
        } else {
            insertionIndex = self.text.endIndex
        }
        var newText = self.text
        newText.insert(contentsOf: text, at: insertionIndex)
        newText = String(newText.prefix(representable.length))
        let newIndex = newText.index(insertionIndex, offsetBy: text.count, limitedBy: newText.endIndex)
        representable.text = newText
        representable.textIndex = newIndex ?? newText.endIndex
    }

    func deleteBackward() {
        guard let currentIndex = representable.textIndex, currentIndex != text.startIndex else {
            return
        }
        let index = text.index(before: currentIndex)
        representable.text.remove(at: index)
        representable.textIndex = index
    }
}

extension CodeFieldViewCoordinator: CodeFieldDelegate {

    func codeField(_ codeField: CodeFieldView, didMoveToWindow window: UIWindow?) {
        updateFocusableViewProxy(with: codeField)
    }

    func codeFieldDidBeginEditing(_ codeField: CodeFieldView) {
        updateFocusableViewProxy(with: codeField)
    }

    func codeFieldDidEndEditing(_ codeField: CodeFieldView) {
        updateFocusableViewProxy(with: codeField)
    }

    // MARK: - Private Methods

    private func updateFocusableViewProxy(with codeField: CodeFieldView) {
        if codeField.window == nil {
            representable.focusableView = .init()
        } else {
            representable.focusableView = .init(uiControl: codeField)
        }
    }
}
