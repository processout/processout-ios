//
//  CodeFieldView.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2024.
//

import UIKit

// swiftlint:disable unused_setter_value

final class CodeFieldView: UIControl, UITextInput {

    init(coordinator: CodeFieldViewCoordinator) {
        self.coordinator = coordinator
        keyboardType = .asciiCapableNumberPad
        textContentType = .oneTimeCode
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIControl

    override var canBecomeFirstResponder: Bool {
        true
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        if isFirstResponder {
            return true
        }
        if super.becomeFirstResponder() {
            sendActions(for: .editingDidBegin)
            return true
        }
        return false
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        if !isFirstResponder {
            return false
        }
        if super.resignFirstResponder() {
            sendActions(for: .editingDidEnd)
            return true
        }
        return false
    }

    override func paste(_ sender: Any?) {
        if let string = UIPasteboard.general.string {
            insertText(string)
        }
    }

    // MARK: - UITextInput

    var inputDelegate: UITextInputDelegate?

    // MARK: - Replacing and returning text

    func text(in range: UITextRange) -> String? {
        guard let range = range as? TextRange else {
            return nil
        }
        // swiftlint:disable:next legacy_objc_type
        return (text as NSString).substring(with: range.range)
    }

    func replace(_ range: UITextRange, withText text: String) {
        // Not supported
    }

    // MARK: - Marked and selected text

    var selectedTextRange: UITextRange? {
        get { nil }
        set { /* Ignored */ }
    }

    private(set) var markedTextRange: UITextRange?

    // Ignored
    var markedTextStyle: [NSAttributedString.Key: Any]?

    func setMarkedText(_ markedText: String?, selectedRange: NSRange) {
        // Not supported
    }

    func unmarkText() {
        // Not supported
    }

    // MARK: - Text ranges and text positions

    func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
        guard let fromPosition = fromPosition as? TextPosition, let toPosition = toPosition as? TextPosition else {
            return nil
        }
        let range = NSRange(
            location: min(fromPosition.offset, toPosition.offset), length: abs(toPosition.offset - fromPosition.offset)
        )
        return TextRange(range: range)
    }

    func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
        guard let position = position as? TextPosition else {
            return nil
        }
        let textOffset = min(max(position.offset + offset, 0), text.count)
        return TextPosition(offset: textOffset)
    }

    func position(from position: UITextPosition, in direction: UITextLayoutDirection, offset: Int) -> UITextPosition? {
        switch direction {
        case .right:
            return self.position(from: position, offset: offset)
        case .left:
            return self.position(from: position, offset: -offset)
        default:
            return position
        }
    }

    var beginningOfDocument: UITextPosition {
        TextPosition(offset: 0)
    }

    var endOfDocument: UITextPosition {
        TextPosition(offset: text.count)
    }

    func compare(_ position: UITextPosition, to other: UITextPosition) -> ComparisonResult {
        guard let position = position as? TextPosition, let other = other as? TextPosition else {
            assertionFailure("Invalid text position class.")
            return .orderedSame
        }
        if position.offset < other.offset {
            return .orderedAscending
        } else if position.offset > other.offset {
            return .orderedDescending
        }
        return .orderedSame
    }

    func offset(from: UITextPosition, to toPosition: UITextPosition) -> Int {
        guard let start = from as? TextPosition, let end = toPosition as? TextPosition else {
            assertionFailure("Invalid text position class.")
            return 0
        }
        return end.offset - start.offset
    }

    // MARK: - Layout and Write Direction

    func position(within range: UITextRange, farthestIn direction: UITextLayoutDirection) -> UITextPosition? {
        guard let range = range as? TextRange else {
            return nil
        }
        let offset: Int
        switch direction {
        case .up, .left:
            offset = range.range.location
        case .right, .down:
            offset = range.range.location + range.range.length
        @unknown default:
            return nil
        }
        return TextPosition(offset: offset)
    }

    func characterRange(byExtending position: UITextPosition, in direction: UITextLayoutDirection) -> UITextRange? {
        guard let position = position as? TextPosition else {
            return nil
        }
        let range: NSRange
        switch direction {
        case .up, .left:
            range = NSRange(location: position.offset - 1, length: 1)
        case .down, .right:
            range = NSRange(location: position.offset, length: 1)
        @unknown default:
            return nil
        }
        return TextRange(range: range)
    }

    func baseWritingDirection(
        for position: UITextPosition, in direction: UITextStorageDirection
    ) -> NSWritingDirection {
        .leftToRight
    }

    func setBaseWritingDirection(_ writingDirection: NSWritingDirection, for range: UITextRange) {
        // Ignored
    }

    // MARK: - Geometry

    func firstRect(for range: UITextRange) -> CGRect {
        bounds
    }

    func caretRect(for position: UITextPosition) -> CGRect {
        .zero
    }

    // MARK: - Hit-testing

    func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        []
    }

    func closestPosition(to point: CGPoint) -> UITextPosition? {
        nil
    }

    func closestPosition(to point: CGPoint, within range: UITextRange) -> UITextPosition? {
        nil
    }

    func characterRange(at point: CGPoint) -> UITextRange? {
        nil
    }

    // MARK: - Tokenizing input text

    private(set) lazy var tokenizer: UITextInputTokenizer = UITextInputStringTokenizer(textInput: self)

    // MARK: - UIKeyInput

    var hasText: Bool {
        coordinator.hasText
    }

    func insertText(_ text: String) {
        if let character = text.last, character.isNewline {
            resignFirstResponder()
        } else {
            coordinator.insertText(text)
        }
    }

    func deleteBackward() {
        coordinator.deleteBackward()
    }

    var keyboardType: UIKeyboardType
    var textContentType: UITextContentType?

    // MARK: - Private Nested Types

    private final class TextPosition: UITextPosition {

        let offset: Int

        init(offset: Int) {
            self.offset = offset
        }
    }

    private final class TextRange: UITextRange {

        let range: NSRange

        override var start: TextPosition {
            TextPosition(offset: range.location)
        }

        override var end: TextPosition {
            TextPosition(offset: range.location + range.length)
        }

        override var isEmpty: Bool {
            range.length == 0
        }

        init(range: NSRange) {
            self.range = range
        }
    }

    // MARK: - Private Properties

    private let coordinator: CodeFieldViewCoordinator

    private var text: String {
        coordinator.text
    }
}

// swiftlint:enable unused_setter_value
