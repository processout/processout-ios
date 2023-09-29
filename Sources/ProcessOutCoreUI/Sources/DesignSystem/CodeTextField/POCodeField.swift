//
//  POCodeField.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 18.09.2023.
//

import SwiftUI

public struct POCodeField: View {

    /// - Parameters:
    ///   - length: code text field length.
    ///   - text: The underlying text to edit.
    ///   - isFocused: You can use this property to observe the focus state of a single view, or programmatically
    ///   set and remove focus from the view.
    public init(length: Int, text: Binding<String>, isFocused: Binding<Bool>) {
        self.length = length
        self.text = text
        self.isFocused = isFocused
    }

    /// - Parameters:
    ///   - length: code text field length.
    ///   - text: The underlying text to edit.
    public init(length: Int, text: Binding<String>) {
        self.length = length
        self.text = text
        self.isFocused = nil
    }

    // MARK: - View

    public var body: some View {
        CodeFieldRepresentable(length: length, text: text, isFocused: isFocused ?? $_isFocused).id(length)
    }

    // MARK: - Private Properties

    private let length: Int
    private let text: Binding<String>
    private let isFocused: Binding<Bool>?

    /// Fallback property to pass down to underlying representable when `isFocused` binding is
    /// not supplied to `init`.
    @State private var _isFocused = false
}

private struct CodeFieldRepresentable: UIViewRepresentable {

    let length: Int

    @Binding var text: String
    @Binding var isFocused: Bool

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> CodeField {
        let textField = CodeField(length: length)
        textField.setContentHuggingPriority(.required, for: .vertical)
        textField.setContentCompressionResistancePriority(.required, for: .vertical)
        textField.setContentHuggingPriority(.required, for: .horizontal)
        textField.setContentCompressionResistancePriority(.required, for: .horizontal)
        context.coordinator.configure(textField: textField)
        return textField
    }

    func updateUIView(_ textField: CodeField, context: Context) {
        let animated = context.transaction.animation != nil
        textField.configure(
            isInvalid: isInvalid, style: style, animated: animated
        )
        if textField.text != text {
            textField.text = text
        }
        updateFirstResponderStatus(textField)
    }

    func makeCoordinator() -> CodeFieldCoordinator {
        CodeFieldCoordinator(view: self)
    }

    // MARK: - Private Properties

    @Environment(\.inputStyle) private var style
    @Environment(\.isControlInvalid) private var isInvalid

    // MARK: - Private Methods

    private func updateFirstResponderStatus(_ textField: CodeField) {
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

private final class CodeFieldCoordinator: NSObject {

    init(view: CodeFieldRepresentable) {
        self.view = view
    }

    func configure(textField: CodeField) {
        textField.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(editingChanged(textField:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
    }

    // MARK: - Private Properties

    private let view: CodeFieldRepresentable

    // MARK: - Private Methods

    @objc private func editingDidBegin() {
        view.isFocused = true
    }

    @objc private func editingChanged(textField: CodeField) {
        view.text = textField.text ?? ""
    }

    @objc private func editingDidEnd() {
        view.isFocused = false
    }
}
