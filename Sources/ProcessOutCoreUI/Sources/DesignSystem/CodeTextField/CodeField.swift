//
//  CodeField.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 23.11.2022.
//

import UIKit

// swiftlint:disable file_length type_body_length unused_setter_value

final class CodeField: UIControl, UITextInput {

    init(length: Int) {
        self.length = length
        carretPosition = .before
        carretPositionIndex = 0
        characters = Array(repeating: nil, count: length)
        keyboardType = .asciiCapableNumberPad
        textContentType = .oneTimeCode
        isInvalid = false
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var text: String? {
        get { String(characters.compactMap { $0 }) }
        set { setText(newValue, sendActions: false) }
    }

    func configure(isInvalid: Bool, style: POInputStyle, animated: Bool) {
        self.style = style
        self.isInvalid = isInvalid
        configureWithCurrentState(animated: animated)
    }

    override var intrinsicContentSize: CGSize {
        let width = CGFloat(length) * (Constants.height + Constants.spacing) - Constants.spacing
        return CGSize(width: width, height: Constants.height)
    }

    // MARK: - UIControl

    override var canBecomeFirstResponder: Bool {
        true
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let didBecomeResponder = super.becomeFirstResponder()
        configureWithCurrentState(animated: true)
        if didBecomeResponder {
            sendActions(for: .editingDidBegin)
        }
        return didBecomeResponder
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        let didResignResponder = super.resignFirstResponder()
        configureWithCurrentState(animated: true)
        if didResignResponder {
            sendActions(for: .editingDidEnd)
        }
        return didResignResponder
    }

    override func paste(_ sender: Any?) {
        if let string = UIPasteboard.general.string {
            setText(string, sendActions: true)
        }
    }

    // MARK: - UITextInput

    var inputDelegate: UITextInputDelegate?

    // MARK: - Replacing and returning text

    func text(in range: UITextRange) -> String? {
        guard let range = range as? TextRange, let text else {
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
        let textOffset = min(max(position.offset + offset, 0), text?.count ?? 0)
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
        TextPosition(offset: text?.count ?? 0)
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

    // MARK: - Layout and Writing Direction

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
        characters.contains { $0 != nil }
    }

    func insertText(_ text: String) {
        if let character = text.last, character.isNewline {
            resignFirstResponder()
            return
        }
        let insertionIndex: Int
        if text.count == length {
            insertionIndex = 0
        } else if case .after = carretPosition, characters[carretPositionIndex] != nil {
            insertionIndex = carretPositionIndex + 1
        } else {
            insertionIndex = carretPositionIndex
        }
        guard characters.indices.contains(insertionIndex) else {
            return
        }
        let insertedText = Array(text.prefix(length - insertionIndex))
        characters.replaceSubrange(insertionIndex ..< insertionIndex + insertedText.count, with: insertedText)
        carretPositionIndex = insertionIndex + insertedText.count
        if carretPositionIndex > length - 1 {
            carretPositionIndex = length - 1
            carretPosition = .after
        } else {
            carretPosition = .before
        }
        configureWithCurrentState(animated: false)
        didChangeEditing()
    }

    func deleteBackward() {
        let removalIndex: Int
        if case .before = carretPosition {
            removalIndex = carretPositionIndex - 1
        } else {
            removalIndex = carretPositionIndex
        }
        guard characters.indices.contains(removalIndex) else {
            return
        }
        characters[removalIndex] = nil
        carretPosition = .before
        carretPositionIndex = removalIndex
        configureWithCurrentState(animated: false)
        didChangeEditing()
    }

    var keyboardType: UIKeyboardType
    var textContentType: UITextContentType?

    // MARK: - Private Nested Types

    private enum Constants {
        static let height: CGFloat = 44
        static let spacing: CGFloat = 6
    }

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

    private let length: Int

    private lazy var contentView: UIStackView = {
        let view = UIStackView()
        view.spacing = Constants.spacing
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var carretPosition: CodeFieldComponentView.CarretPosition
    private var carretPositionIndex: Int
    private var characters: [Character?]
    private var style: POInputStyle?
    private var isInvalid: Bool

    private var groupViews: [CodeFieldComponentView] {
        // swiftlint:disable:next force_cast
        contentView.arrangedSubviews as! [CodeFieldComponentView]
    }

    // MARK: - Views Hierarchy

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        let constraints = [
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        stride(from: 0, to: length, by: 1)
            .map(createCodeTextFieldComponentView)
            .forEach(contentView.addArrangedSubview)
        addContextMenuGesture()
        isAccessibilityElement = true
    }

    private func createCodeTextFieldComponentView(index: Int) -> CodeFieldComponentView {
        let size = CGSize(width: Constants.height, height: Constants.height)
        let view = CodeFieldComponentView(size: size) { [weak self] position in
            self?.setCarretPosition(position: position, index: index)
        }
        return view
    }

    // MARK: - Utils

    private func setCarretPosition(position: CodeFieldComponentView.CarretPosition, index: Int) {
        if !isFirstResponder {
            becomeFirstResponder()
        } else if characters.indices.contains(index) {
            let updatedCarretPosition: CodeFieldComponentView.CarretPosition
            if characters[index] != nil {
                updatedCarretPosition = position
            } else {
                updatedCarretPosition = .before
            }
            if carretPositionIndex == index, carretPosition == updatedCarretPosition {
                showContextMenu()
            } else {
                carretPositionIndex = index
                carretPosition = updatedCarretPosition
            }
            configureWithCurrentState(animated: true)
        } else {
            assertionFailure("Invalid index.")
        }
    }

    private func setText(_ text: String?, sendActions: Bool) {
        guard self.text != text else {
            return
        }
        characters = Array(repeating: nil, count: length)
        if let text, !text.isEmpty {
            let insertedTextCharacters = Array(text.prefix(length))
            characters.replaceSubrange(0 ..< insertedTextCharacters.count, with: insertedTextCharacters)
            carretPositionIndex = min(insertedTextCharacters.count, length - 1)
            carretPosition = insertedTextCharacters.count == length ? .after : .before
        } else {
            carretPositionIndex = 0
            carretPosition = .before
        }
        configureWithCurrentState(animated: false)
        didChangeEditing(sendActions: sendActions)
    }

    private func configureWithCurrentState(animated: Bool) {
        guard let style else {
            return
        }
        let stateStyle = isInvalid ? style.error : style.normal
        characters.enumerated().forEach { offset, character in
            let viewModel = CodeFieldComponentView.ViewModel(
                value: character,
                carretPosition: isFirstResponder && carretPositionIndex == offset ? carretPosition : nil,
                style: stateStyle
            )
            groupViews[offset].configure(viewModel: viewModel, animated: animated)
        }
        accessibilityValue = text
    }

    private func didChangeEditing(sendActions: Bool = true) {
        if sendActions {
            self.sendActions(for: .editingChanged)
        }
        UIMenuController.shared.hideMenu(from: self)
    }

    // MARK: - Context Menu

    private func addContextMenuGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(showContextMenu))
        contentView.addGestureRecognizer(gesture)
    }

    @objc
    private func showContextMenu() {
        let controller = UIMenuController.shared
        controller.showMenu(from: self, rect: contentView.frame)
    }
}

// swiftlint:enable file_length type_body_length unused_setter_value
