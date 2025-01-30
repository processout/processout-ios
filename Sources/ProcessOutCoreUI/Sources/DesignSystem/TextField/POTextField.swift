//
//  POTextField.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 06.09.2023.
//

import SwiftUI

@_spi(PO)
@available(iOS 14, *)
@MainActor
public struct POTextField<Trailing: View>: View {

    /// - Parameters:
    ///   - text: The underlying text to edit.
    ///   - formatter: A formatter to use when converting between the string the user edits and the underlying value.
    ///   If `formatter` can't perform the conversion, the text field doesn't modify `binding.value`.
    ///   - prompt: A `String` which provides users with guidance on what to enter into the text field.
    public init(
        text: Binding<String>,
        formatter: Formatter? = nil,
        prompt: String = "",
        trailingView: Trailing = EmptyView()
    ) {
        self._text = text
        self.formatter = formatter
        self.prompt = prompt
        self.trailingView = trailingView
    }

    public var body: some View {
        let configuration = POTextFieldStyleConfiguration(
            text: $text,
            isEditing: focusCoordinator.isEditing,
            textField: {
                TextFieldRepresentable(text: $text, formatter: formatter)
            },
            prompt: Text(prompt),
            trailingView: {
                trailingView
            }
        )
        AnyView(style.makeBody(configuration: configuration))
    }

    // MARK: - Private Properties

    private let formatter: Formatter?
    private let prompt: String
    private let trailingView: Trailing

    @Binding
    private var text: String

    @Environment(\.poTextFieldStyle)
    private var style

    @EnvironmentObject
    private var focusCoordinator: FocusCoordinator
}

private enum Constants {
    static let minHeight: CGFloat = 48
    static let padding = EdgeInsets(horizontal: POSpacing.medium, vertical: POSpacing.extraSmall)
}

@available(iOS 14, *)
@MainActor
private struct TextFieldRepresentable: UIViewRepresentable {

    init(text: Binding<String>, formatter: Formatter?) {
        self._text = text
        self._multiplier = .init(wrappedValue: 1)
        self.formatter = formatter
    }

    let formatter: Formatter?

    @Binding
    var text: String

    // MARK: - UIViewRepresentable

    typealias Coordinator = TextFieldCoordinator

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.adjustsFontForContentSizeCategory = false
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        context.coordinator.configure(textField: textField)
        focusCoordinator.track(control: textField)
        return textField
    }

    func updateUIView(_ textField: UITextField, context: Context) {
        context.coordinator.view = self
        let animated = context.transaction.animation != nil
        UIView.perform(withAnimation: animated, duration: 0.25) {
            updateText(textField)
            UIView.performWithoutAnimation(textField.layoutIfNeeded)
        }
        textField.keyboardType = keyboardType
        textField.textContentType = textContentType
        textField.returnKeyType = submitLabel.returnKeyType
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(view: self)
    }

    // MARK: -

    func willReturn() {
        submitAction()
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let animationDuration: TimeInterval = 0.25
    }

    // MARK: - Private Properties

    @POBackport.ScaledMetric
    private var multiplier: CGFloat

    @Environment(\.textStyle)
    private var textStyle

    @Environment(\.poKeyboardType)
    private var keyboardType

    @Environment(\.poTextContentType)
    private var textContentType

    @Environment(\.backportSubmitLabel)
    private var submitLabel

    @Environment(\.backportSubmitAction)
    private var submitAction

    @EnvironmentObject
    private var focusCoordinator: FocusCoordinator

    // MARK: - Private Methods

    private func updateText(_ textField: UITextField) {
        if textField.text != text {
            textField.text = text
        }
        let multiplier = $multiplier.value(with: textStyle.typography.textStyle)
        textField.font = textStyle.typography.font.withSize(textStyle.typography.font.pointSize * multiplier)
        textField.textColor = UIColor(textStyle.color)
    }
}

@available(iOS 14, *)
private final class TextFieldCoordinator: NSObject, UITextFieldDelegate {

    init(view: TextFieldRepresentable) {
        self.view = view
    }

    func configure(textField: UITextField) {
        textField.delegate = self
        textField.addTarget(self, action: #selector(editingChanged(textField:)), for: .editingChanged)
    }

    var view: TextFieldRepresentable

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.willReturn()
        return true
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

    // MARK: - Private Methods

    @objc private func editingChanged(textField: UITextField) {
        view.text = textField.text ?? ""
    }
}
