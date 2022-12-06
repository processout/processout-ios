//
//  CodeTextField.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.11.2022.
//

import UIKit

final class CodeTextField: UIControl, UIKeyInput, InputFormTextFieldType {

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
        set { setText(newValue) }
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
        characters.replaceSubrange(insertionIndex ..< insertionIndex + insertedText.count, with: insertedText)
        carretPositionIndex += insertedText.count
        if carretPositionIndex > length - 1 {
            carretPositionIndex = length - 1
            carretPosition = .after
        } else {
            carretPosition = .before
        }
        configureWithCurrentState(animated: false)
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
        characters[removalIndex] = nil
        carretPosition = .before
        carretPositionIndex = removalIndex
        configureWithCurrentState(animated: false)
        sendActions(for: .editingChanged)
    }

    var keyboardType: UIKeyboardType
    var returnKeyType: UIReturnKeyType

    /// The semantic meaning for a text input area.
    /// Default value is `oneTimeCode` on iOS >= 12 and `nil` otherwise.
    var textContentType: UITextContentType?

    // MARK: - Private Nested Types

    private enum Constants {
        static let height: CGFloat = 48
        static let spacing: CGFloat = 8
        static let minimumSpacing: CGFloat = 6
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
        if #available(iOS 12.0, *) {
            textContentType = .oneTimeCode
        }
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
        configureWithCurrentState(animated: false)
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
        configureWithCurrentState(animated: true)
    }

    private func setText(_ text: String?) {
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
    }

    private func createCodeTextFieldComponentView(index: Int) -> CodeTextFieldComponentView {
        let view = CodeTextFieldComponentView { [weak self] position in
            self?.setCarretPosition(position: position, index: index)
            self?.becomeFirstResponder()
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
    }
}
