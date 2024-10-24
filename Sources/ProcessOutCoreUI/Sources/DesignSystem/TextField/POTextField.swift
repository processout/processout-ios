//
//  POTextField.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 06.09.2023.
//

import SwiftUI

@_spi(PO)
@available(iOS 14, *)
public struct POTextField<Trailing: View>: View {

    /// - Parameters:
    ///   - text: The underlying text to edit.
    ///   - formatter: A formatter to use when converting between the string the user edits and the underlying value.
    ///   If `formatter` can't perform the conversion, the text field doesn't modify `binding.value`.
    ///   - prompt: A `String` which provides users with guidance on what to enter into the text field.
    public init(
        text: Binding<String>, formatter: Formatter? = nil, prompt: String = "", trailingView: Trailing = EmptyView()
    ) {
        self._text = text
        self.formatter = formatter
        self.prompt = prompt
        self.trailingView = trailingView
    }

    public var body: some View {
        let style = style.resolve(isInvalid: isInvalid, isFocused: focusCoordinator.isEditing)
        HStack {
            ZStack(alignment: .leading) {
                TextFieldRepresentable(text: $text, formatter: formatter, style: style)
                Text(prompt)
                    .lineLimit(1)
                    .textStyle(style.placeholder)
                    .allowsHitTesting(false)
                    .opacity(text.isEmpty ? 1 : 0)
                    .transaction { transaction in
                        transaction.animation = nil
                    }
            }
            trailingView.foregroundColor(text.isEmpty ? style.placeholder.color : style.text.color)
        }
        .padding(Constants.padding)
        .frame(maxWidth: .infinity, minHeight: Constants.minHeight)
        .background(style.backgroundColor)
        .border(style: style.border)
        .shadow(style: style.shadow)
        .accentColor(style.tintColor)
        .animation(.default, value: isInvalid)
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    private let formatter: Formatter?
    private let prompt: String
    private let trailingView: Trailing

    @Binding
    private var text: String

    @Environment(\.inputStyle)
    private var style

    @Environment(\.isControlInvalid)
    private var isInvalid

    @EnvironmentObject
    private var focusCoordinator: FocusCoordinator
}

private enum Constants {
    static let minHeight: CGFloat = 48
    static let padding = EdgeInsets(horizontal: POSpacing.medium, vertical: POSpacing.extraSmall)
}

@available(iOS 14, *)
private struct TextFieldRepresentable: UIViewRepresentable {

    init(text: Binding<String>, formatter: Formatter?, style: POInputStateStyle) {
        self._text = text
        self.formatter = formatter
        self.style = style
        _multiplier = .init(wrappedValue: 1, relativeTo: style.text.typography.textStyle)
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

    private let style: POInputStateStyle

    @POBackport.ScaledMetric
    private var multiplier: CGFloat

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
        textField.font = style.text.typography.font.withSize(style.text.typography.font.pointSize * multiplier)
        textField.textColor = UIColor(style.text.color)
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
