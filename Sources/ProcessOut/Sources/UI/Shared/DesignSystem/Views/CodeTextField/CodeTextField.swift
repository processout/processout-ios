//
//  CodeTextField.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.11.2022.
//

import UIKit

// swiftlint:disable file_length type_body_length unused_setter_value

final class CodeTextField: UIControl, UITextInput, InputFormTextFieldType {

    init(length: Int) {
        self.length = length
        groupViews = []
        carretPosition = .before
        carretPositionIndex = 0
        characters = Array(repeating: nil, count: length)
        keyboardType = .default
        returnKeyType = .default
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    weak var delegate: CodeTextFieldDelegate?

    var text: String? {
        get { String(characters.compactMap { $0 }) }
        set { setText(newValue, sendActions: false) }
    }

    func configure(style: POTextFieldStyle, animated: Bool) {
        self.style = style
        configureWithCurrentState(animated: animated)
    }

    var control: UIControl {
        self
    }

    // MARK: - UIControl

    override var canBecomeFirstResponder: Bool {
        true
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        if delegate?.codeTextFieldShouldBeginEditing(self) == false {
            return false
        }
        let didBecomeResponder = super.becomeFirstResponder()
        configureWithCurrentState(animated: true)
        return didBecomeResponder
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        let didResignResponder = super.resignFirstResponder()
        configureWithCurrentState(animated: true)
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
            if delegate?.codeTextFieldShouldReturn(self) != false {
                resignFirstResponder()
            }
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
    var returnKeyType: UIReturnKeyType
    var textContentType: UITextContentType?

    // MARK: - Private Nested Types

    private enum Constants {
        static let height: CGFloat = 48
        static let spacing: CGFloat = 8
        static let minimumSpacing: CGFloat = 6
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

    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var groupViews: [CodeTextFieldComponentView]
    private var carretPosition: CodeTextFieldCarretPosition
    private var carretPositionIndex: Int
    private var characters: [Character?]
    private var style: POTextFieldStyle?

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        let fixedLeadingConstraint = contentView.leadingAnchor.constraint(equalTo: leadingAnchor)
        fixedLeadingConstraint.priority = .defaultLow
        let constraints = [
            contentView.heightAnchor.constraint(equalToConstant: Constants.height),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            fixedLeadingConstraint
        ]
        NSLayoutConstraint.activate(constraints)
        createGroupViews()
        addContextMenuGesture()
        isAccessibilityElement = true
    }

    private func createGroupViews() {
        groupViews.forEach { view in
            view.removeFromSuperview()
        }
        groupViews = stride(from: 0, to: length, by: 1).map(createCodeTextFieldComponentView)
        var constraints = [
            groupViews[0].leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            groupViews[groupViews.count - 1].trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]
        groupViews.enumerated().forEach { offset, groupView in
            contentView.addSubview(groupView)
            var viewConstraints = [
                groupView.topAnchor.constraint(equalTo: contentView.topAnchor),
                groupView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ]
            if groupViews.indices.contains(offset + 1) {
                let nextView = groupViews[offset + 1]
                let constraints = [
                    nextView.leadingAnchor
                        .constraint(equalTo: groupView.trailingAnchor, constant: Constants.spacing)
                        .with(priority: .defaultLow),
                    nextView.leadingAnchor.constraint(
                        greaterThanOrEqualTo: groupView.trailingAnchor, constant: Constants.minimumSpacing
                    ),
                    nextView.widthAnchor.constraint(equalTo: groupView.widthAnchor)
                ]
                viewConstraints.append(contentsOf: constraints)
            }
            constraints.append(contentsOf: viewConstraints)
        }
        NSLayoutConstraint.activate(constraints)
    }

    private func setCarretPosition(position: CodeTextFieldCarretPosition, index: Int) {
        if !isFirstResponder {
            becomeFirstResponder()
        } else if characters.indices.contains(index) {
            let updatedCarretPosition: CodeTextFieldCarretPosition
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

    private func createCodeTextFieldComponentView(index: Int) -> CodeTextFieldComponentView {
        let view = CodeTextFieldComponentView { [weak self] position in
            self?.setCarretPosition(position: position, index: index)
        }
        return view
    }

    private func configureWithCurrentState(animated: Bool) {
        guard let style else {
            return
        }
        characters.enumerated().forEach { offset, character in
            let viewModel = CodeTextFieldComponentView.ViewModel(
                value: character,
                carretPosition: isFirstResponder && carretPositionIndex == offset ? carretPosition : nil,
                style: style
            )
            groupViews[offset].configure(viewModel: viewModel, animated: animated)
        }
        accessibilityValue = text
    }

    private func didChangeEditing(sendActions: Bool = true) {
        if sendActions {
            self.sendActions(for: .editingChanged)
        }
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }

    // MARK: - Context Menu

    private func addContextMenuGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(showContextMenu))
        contentView.addGestureRecognizer(gesture)
    }

    @objc
    private func showContextMenu() {
        let controller = UIMenuController.shared
        if #available(iOS 13.0, *) {
            controller.showMenu(from: self, rect: contentView.frame)
        } else {
            controller.setTargetRect(contentView.frame, in: self)
            controller.setMenuVisible(true, animated: true)
        }
    }
}
