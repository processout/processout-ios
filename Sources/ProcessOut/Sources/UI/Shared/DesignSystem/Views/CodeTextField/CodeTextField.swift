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

    var style: POTextFieldStyle {
        didSet { configureWithCurrentState() }
    }

    var text: String {
        String(characters.compactMap { $0 })
    }

    // MARK: - UIControl

    override var canBecomeFirstResponder: Bool {
        true
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let didBecomeResponder = super.becomeFirstResponder()
        configureWithCurrentState()
        return didBecomeResponder
    }

    // MARK: - UIKeyInput

    var hasText: Bool {
        characters.contains { $0 != nil }
    }

    func insertText(_ text: String) {
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
        characters[removalIndex] = nil
        carretPosition = .before
        carretPositionIndex = removalIndex
        configureWithCurrentState()
        sendActions(for: .editingChanged)
    }

    var keyboardType: UIKeyboardType
    var returnKeyType: UIReturnKeyType
    var textContentType: UITextContentType! // swiftlint:disable:this implicitly_unwrapped_optional

    // MARK: - Private Nested Types

    private enum Constants {
        static let height: CGFloat = 48
        static let spacing: CGFloat = 8
        static let minimumSpacing: CGFloat = 6
    }

    // MARK: - Private Properties

    private let length: Int

    private lazy var groupViews: [CodeTextFieldComponentView] = {
        let views = stride(from: 0, to: length, by: 1).map { offset in
            let view = CodeTextFieldComponentView(style: style) { [weak self] position in
                self?.setCarretPosition(position: position, index: offset)
            }
            return view
        }
        return views
    }()

    private var carretPosition: CodeTextFieldCarretPosition
    private var carretPositionIndex: Int
    private var characters: [Character?]

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = [
            groupViews[0].leadingAnchor.constraint(equalTo: leadingAnchor),
            groupViews[groupViews.count - 1].trailingAnchor.constraint(equalTo: trailingAnchor),
            heightAnchor.constraint(equalToConstant: Constants.height)
        ]
        groupViews.enumerated().forEach { offset, groupView in
            addSubview(groupView)
            var viewConstraints = [
                groupView.topAnchor.constraint(equalTo: topAnchor),
                groupView.centerYAnchor.constraint(equalTo: centerYAnchor)
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
        configureWithCurrentState()
    }

    private func setCarretPosition(position: CodeTextFieldCarretPosition, index: Int) {
        becomeFirstResponder()
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
