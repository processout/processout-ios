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
    public init(length: Int, text: Binding<String>) {
        self.length = length
        self.text = text
    }

    // MARK: - View

    public var body: some View {
        CodeFieldRepresentable(length: length, text: text).id(length)
    }

    // MARK: - Private Properties

    private let length: Int
    private let text: Binding<String>
}

private struct CodeFieldRepresentable: UIViewRepresentable {

    let length: Int
    @Binding var text: String

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> CodeField {
        let codeField = CodeField(length: length)
        codeField.setContentHuggingPriority(.required, for: .vertical)
        codeField.setContentCompressionResistancePriority(.required, for: .vertical)
        codeField.setContentHuggingPriority(.required, for: .horizontal)
        codeField.setContentCompressionResistancePriority(.required, for: .horizontal)
        context.coordinator.configure(codeField: codeField)
        focusCoordinator?.track(control: codeField)
        return codeField
    }

    func updateUIView(_ codeField: CodeField, context: Context) {
        let animated = context.transaction.animation != nil
        codeField.configure(isInvalid: isInvalid, style: style, animated: animated)
        if codeField.text != text {
            codeField.text = text
        }
    }

    func makeCoordinator() -> CodeFieldCoordinator {
        CodeFieldCoordinator(view: self)
    }

    // MARK: - Private Properties

    @Environment(\.inputStyle) private var style
    @Environment(\.isControlInvalid) private var isInvalid
    @Environment(\.focusCoordinator) private var focusCoordinator
}

private final class CodeFieldCoordinator: NSObject {

    init(view: CodeFieldRepresentable) {
        self.view = view
    }

    func configure(codeField: CodeField) {
        codeField.addTarget(self, action: #selector(editingChanged(textField:)), for: .editingChanged)
    }

    // MARK: - Private Properties

    private let view: CodeFieldRepresentable

    // MARK: - Private Methods

    @objc private func editingChanged(textField: CodeField) {
        view.text = textField.text ?? ""
    }
}
