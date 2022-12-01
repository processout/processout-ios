//
//  CodeTextField.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.11.2022.
//

import UIKit

final class CodeTextField: UIControl, UIKeyInput {

    init(length: Int, style: POTextFieldStyle) {
        self.length = length
        self.style = style
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

    var style: POTextFieldStyle {
        didSet { configureWithCurrentState() }
    }

    var text: String? {
        get { String(characters.compactMap { $0 }) }
        set { setText(newValue) }
    }

    var length: Int {
        didSet { didUpdateLength(oldValue: oldValue) }
    }

    var keyboardType: UIKeyboardType
    var returnKeyType: UIReturnKeyType
    var textContentType: UITextContentType! // swiftlint:disable:this implicitly_unwrapped_optional

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
        configureWithCurrentState()
        return didBecomeResponder
    }

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
        if case .after = carretPosition, characters[carretPositionIndex] != nil {
            insertionIndex = carretPositionIndex + 1
        } else {
            insertionIndex = carretPositionIndex
        }
        guard characters.indices.contains(insertionIndex) else {
            return
        }
        let insertedText = Array(text.prefix(length - insertionIndex))
        let updatedRange = NSRange(
            location: max(insertionIndex - characters.prefix(insertionIndex).filter { $0 == nil }.count, 0),
            length: 0
        )
        if delegate?.codeTextField(self, shouldChangeCharactersIn: updatedRange, replacementString: text) == false {
            return
        }
        characters.replaceSubrange(insertionIndex ..< insertionIndex + insertedText.count, with: insertedText)
        carretPositionIndex += insertedText.count
        if carretPositionIndex > length - 1 {
            carretPositionIndex = length - 1
            carretPosition = .after
        } else {
            carretPosition = .before
        }
        configureWithCurrentState()
        sendActions(for: .editingChanged)
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
        let updatedRange = NSRange(
            location: removalIndex - characters.prefix(removalIndex + 1).filter { $0 == nil }.count, length: 1
        )
        if updatedRange.location >= 0,
           delegate?.codeTextField(self, shouldChangeCharactersIn: updatedRange, replacementString: "") == false {
            return
        }
        characters[removalIndex] = nil
        carretPosition = .before
        carretPositionIndex = removalIndex
        configureWithCurrentState()
        sendActions(for: .editingChanged)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let height: CGFloat = 48
        static let spacing: CGFloat = 8
        static let minimumSpacing: CGFloat = 6
    }

    // MARK: - Private Properties

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
        recreateGroupViews()
        configureWithCurrentState()
    }

    private func recreateGroupViews() {
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
                let spacingConstraint = nextView.leadingAnchor.constraint(
                    equalTo: groupView.trailingAnchor, constant: Constants.spacing
                )
                spacingConstraint.priority = .defaultLow
                let minimumSpacingConstraint = nextView.leadingAnchor.constraint(
                    greaterThanOrEqualTo: groupView.trailingAnchor, constant: Constants.minimumSpacing
                )
                viewConstraints.append(contentsOf: [spacingConstraint, minimumSpacingConstraint])
            }
            constraints.append(contentsOf: viewConstraints)
        }
        NSLayoutConstraint.activate(constraints)
    }

    private func setCarretPosition(position: CodeTextFieldCarretPosition, index: Int) {
        guard characters.indices.contains(index) else {
            assertionFailure("Invalid index.")
            return
        }
        carretPositionIndex = index
        if characters[index] != nil {
            carretPosition = position
        } else {
            carretPosition = .before
        }
        configureWithCurrentState()
    }

    private func setText(_ text: String?) {
        characters = Array(repeating: nil, count: length)
        if let text, !text.isEmpty {
            let insertedTextCharacters = Array(text.prefix(length))
            characters.replaceSubrange(0 ..< insertedTextCharacters.count, with: insertedTextCharacters)
        }
        carretPosition = .before
        carretPositionIndex = 0
        configureWithCurrentState()
    }

    private func didUpdateLength(oldValue: Int) {
        assert(length > 0, "Length must be greater than zero.")
        guard length != oldValue else {
            return
        }
        if length > oldValue {
            let difference = length - oldValue
            characters.append(contentsOf: Array(repeating: nil, count: difference))
            recreateGroupViews()
        } else {
            if carretPositionIndex >= length {
                carretPositionIndex = length - 1
                carretPosition = characters[carretPositionIndex] != nil ? .after : .before
            }
            let difference = oldValue - length
            characters.removeLast(difference)
            groupViews.removeLast(difference)
        }
        configureWithCurrentState()
    }

    private func createCodeTextFieldComponentView(index: Int) -> CodeTextFieldComponentView {
        let view = CodeTextFieldComponentView(style: style) { [weak self] position in
            self?.setCarretPosition(position: position, index: index)
            self?.becomeFirstResponder()
        }
        return view
    }

    private func configureWithCurrentState() {
        characters.enumerated().forEach { offset, character in
            let groupView = groupViews[offset]
            groupView.carretPosition = nil
            groupView.value = character
            groupView.style = style
        }
        if isFirstResponder {
            groupViews[carretPositionIndex].carretPosition = carretPosition
        }
    }
}
