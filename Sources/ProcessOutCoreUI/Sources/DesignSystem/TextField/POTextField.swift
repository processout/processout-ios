//
//  POTextField.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 06.09.2023.
//

import SwiftUI

public struct POTextField: View {

    /// - Parameters:
    ///   - text: The underlying text to edit.
    ///   - formatter: A formatter to use when converting between the string the user edits and the underlying value.
    ///   If `formatter` can't perform the conversion, the text field doesn't modify `binding.value`.
    ///   - prompt: A `String` which provides users with guidance on what to enter into the text field.
    ///   - isFocused: You can use this property to observe the focus state of a single view, or programmatically
    ///   set and remove focus from the view.
    ///   - onCommit: An action to perform when the user performs an action (for example, when the user
    ///   presses the return key) while the text field has focus.
    public init(
        text: Binding<String>,
        formatter: Formatter? = nil,
        prompt: String = "",
        isFocused: Binding<Bool>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.text = text
        self.formatter = formatter
        self.prompt = prompt
        self.isFocused = isFocused
        self.onCommit = onCommit
    }

    /// - Parameters:
    ///   - text: The underlying text to edit.
    ///   - formatter: A formatter to use when converting between the string the user edits and the underlying value.
    ///   If `formatter` can't perform the conversion, the text field doesn't modify `binding.value`.
    ///   - prompt: A `String` which provides users with guidance on what to enter into the text field.
    ///   - onCommit: An action to perform when the user performs an action (for example, when the user
    ///   presses the return key) while the text field has focus.
    public init(
        text: Binding<String>,
        formatter: Formatter? = nil,
        prompt: String = "",
        onCommit: @escaping () -> Void = { }
    ) {
        self.text = text
        self.formatter = formatter
        self.prompt = prompt
        self.isFocused = nil
        self.onCommit = onCommit
    }

    public var body: some View {
        let style = isInvalid ? style.error : style.normal
        TextFieldRepresentable(
            text: text,
            isFocused: isFocused ?? $_isFocused,
            formatter: formatter,
            prompt: prompt,
            style: style,
            onCommit: onCommit
        )
        .padding(Constants.padding)
        .frame(maxWidth: .infinity, minHeight: Constants.height)
        .background(Color(style.backgroundColor))
        .border(style: style.border)
        .shadow(style: style.shadow)
        .accentColor(Color(style.tintColor))
        .animation(.default, value: isInvalid)
    }

    // MARK: - Nested Types

    private enum Constants {
        static let height: CGFloat = 44
        static let padding = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    }

    // MARK: - Private Properties

    private let text: Binding<String>
    private let formatter: Formatter?
    private let prompt: String
    private let isFocused: Binding<Bool>?
    private let onCommit: () -> Void

    /// Fallback property to pass down to underlying representable when `isFocused` binding is
    /// not supplied to `init`.
    @State private var _isFocused = false

    @Environment(\.inputStyle) private var style
    @Environment(\.isControlInvalid) private var isInvalid
}

// todo(andrii-vysotskyi): support textContentType
private struct TextFieldRepresentable: UIViewRepresentable {

    @Binding var text: String
    @Binding var isFocused: Bool

    let formatter: Formatter?
    let prompt: String
    let style: POInputStateStyle
    let onCommit: () -> Void

    // MARK: - UIViewRepresentable

    typealias Coordinator = TextFieldCoordinator

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setContentHuggingPriority(.required, for: .vertical)
        textField.setContentCompressionResistancePriority(.required, for: .vertical)
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.adjustsFontForContentSizeCategory = false
        context.coordinator.configure(textField: textField)
        updateUIView(textField, context: context)
        return textField
    }

    func updateUIView(_ textField: UITextField, context: Context) {
        let animated = context.transaction.animation != nil
        UIView.perform(withAnimation: animated, duration: 0.25) {
            updateText(textField)
            updatePlaceholder(textField)
            UIView.performWithoutAnimation(textField.layoutIfNeeded)
        }
        updateFirstResponderStatus(textField)
        textField.returnKeyType = returnKeyType
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(view: self)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let animationDuration: TimeInterval = 0.25
        static let excludedTextAttributes: Set<NSAttributedString.Key> = [.paragraphStyle, .baselineOffset]
    }

    // MARK: - Private Properties

    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.returnKeyType) private var returnKeyType

    // MARK: - Private Methods

    /// Internal implementation changes `defaultTextAttributes` which overwrites placeholder
    /// attributes so placeholder must be configured after text.
    private func updateText(_ textField: UITextField) {
        if textField.text != text {
            textField.text = text
        }
        let textAttributes = AttributedStringBuilder()
            .with { builder in
                builder.typography = style.text.typography
                builder.sizeCategory = .init(sizeCategory)
                builder.color = style.text.color
            }
            .buildAttributes()
            .filter { !Constants.excludedTextAttributes.contains($0.key) }
        textField.defaultTextAttributes = textAttributes
    }

    private func updatePlaceholder(_ textField: UITextField) {
        let updatedPlaceholder = AttributedStringBuilder()
            .with { builder in
                builder.typography = style.placeholder.typography
                builder.sizeCategory = .init(sizeCategory)
                builder.color = style.placeholder.color
                builder.text = .plain(prompt)
            }
            .build()
        if textField.attributedPlaceholder != updatedPlaceholder {
            textField.attributedPlaceholder = updatedPlaceholder
        }
    }

    private func updateFirstResponderStatus(_ textField: UITextField) {
        // todo(andrii-vysotskyi): reference implementations are wrapping this
        // into dispatch async, inspect why it may be needed.
        guard textField.window != nil else {
            return
        }
        if isFocused {
            guard !textField.isFirstResponder else {
                return
            }
            textField.becomeFirstResponder()
        } else if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
}

private final class TextFieldCoordinator: NSObject, UITextFieldDelegate {

    init(view: TextFieldRepresentable) {
        self.view = view
    }

    func configure(textField: UITextField) {
        textField.delegate = self
        textField.addTarget(self, action: #selector(editingChanged(textField:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(editingDidEndOnExit), for: .editingDidEndOnExit)
    }

    // MARK: - UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.isFocused = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        view.isFocused = false
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let formatter = view.formatter else {
            return true
        }
        // swiftlint:disable legacy_objc_type
        let originalString = (textField.text ?? "") as NSString
        var updatedString = originalString.replacingCharacters(in: range, with: string) as NSString
        // swiftlint:enable legacy_objc_type
        var proposedSelectedRange = NSRange(location: updatedString.length, length: 0)
        let isReplacementValid = formatter.isPartialStringValid(
            &updatedString,
            proposedSelectedRange: &proposedSelectedRange,
            originalString: originalString as String,
            originalSelectedRange: range,
            errorDescription: nil
        )
        guard isReplacementValid else {
            return false
        }
        textField.text = updatedString as String
        // swiftlint:disable:next line_length
        if let position = textField.position(from: textField.beginningOfDocument, offset: proposedSelectedRange.lowerBound) {
            // fixme(andrii-vysotskyi): when called as a result of paste system changes our selection to wrong value
            // based on length of `replacementString` after call textField(:shouldChangeCharactersIn:replacementString:)
            // returns, even if this method returns false.
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
        textField.sendActions(for: .editingChanged)
        return false
    }

    // MARK: - Private Properties

    private let view: TextFieldRepresentable

    // MARK: - Private Methods

    @objc private func editingChanged(textField: UITextField) {
        view.text = textField.text ?? ""
    }

    @objc private func editingDidEndOnExit() {
        view.onCommit()
    }
}
