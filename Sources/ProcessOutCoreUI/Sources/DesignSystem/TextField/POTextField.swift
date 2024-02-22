//
//  POTextField.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 06.09.2023.
//

import SwiftUI

@available(iOS 14, *)
@_spi(PO)
public struct POTextField<Trailing: View>: View {

    /// - Parameters:
    ///   - text: The underlying text to edit.
    ///   - formatter: A formatter to use when converting between the string the user edits and the underlying value.
    ///   If `formatter` can't perform the conversion, the text field doesn't modify `binding.value`.
    ///   - prompt: A `String` which provides users with guidance on what to enter into the text field.
    public init(
        text: Binding<String>, formatter: Formatter? = nil, prompt: String = "", trailingView: Trailing = EmptyView()
    ) {
        self.text = text
        self.formatter = formatter
        self.prompt = prompt
        self.trailingView = trailingView
    }

    public var body: some View {
        let style = isInvalid ? style.error : style.normal
        HStack {
            POHorizontalSizeReader { width in
                TextFieldRepresentable(
                    text: text,
                    formatter: formatter,
                    prompt: prompt,
                    preferredWidth: width,
                    style: style
                )
            }
            trailingView
        }
        .padding(Constants.padding)
        .frame(maxWidth: .infinity, minHeight: Constants.minHeight)
        .background(style.backgroundColor)
        .border(style: style.border)
        .shadow(style: style.shadow)
        .accentColor(style.tintColor)
        .backport.geometryGroup()
        .animation(.default, value: isInvalid)
    }

    // MARK: - Private Properties

    private let text: Binding<String>
    private let formatter: Formatter?
    private let prompt: String
    private let trailingView: Trailing

    @Environment(\.inputStyle) private var style
    @Environment(\.isControlInvalid) private var isInvalid
}

private enum Constants {
    static let minHeight: CGFloat = 44
    static let padding = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
}

@available(iOS 14, *)
private struct TextFieldRepresentable: UIViewRepresentable {

    @Binding var text: String

    let formatter: Formatter?
    let prompt: String
    let preferredWidth: CGFloat
    let style: POInputStateStyle

    // MARK: - UIViewRepresentable

    typealias Coordinator = TextFieldCoordinator

    func makeUIView(context: Context) -> TextField {
        let textField = TextField()
        context.coordinator.configure(textField: textField)
        focusCoordinator?.track(control: textField)
        return textField
    }

    func updateUIView(_ textField: TextField, context: Context) {
        context.coordinator.view = self
        let animated = context.transaction.animation != nil
        UIView.perform(withAnimation: animated, duration: 0.25) {
            updateText(textField)
            updatePlaceholder(textField)
            UIView.performWithoutAnimation(textField.layoutIfNeeded)
        }
        textField.keyboardType = keyboardType
        textField.textContentType = textContentType
        textField.returnKeyType = submitLabel.returnKeyType
        textField.preferredWidth = preferredWidth
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(view: self)
    }

    // MARK: -

    func willReturn() {
        submitAction?()
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let animationDuration: TimeInterval = 0.25
        static let includedTextAttributes: Set<NSAttributedString.Key> = [.foregroundColor, .font]
    }

    // MARK: - Private Properties

    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.poKeyboardType) private var keyboardType
    @Environment(\.poTextContentType) private var textContentType
    @Environment(\.backportSubmitLabel) private var submitLabel
    @Environment(\.backportSubmitAction) private var submitAction
    @Environment(\.focusCoordinator) private var focusCoordinator

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
                builder.color = UIColor(style.text.color)
            }
            .buildAttributes()
            .filter { Constants.includedTextAttributes.contains($0.key) }
        textField.defaultTextAttributes = textAttributes
    }

    private func updatePlaceholder(_ textField: UITextField) {
        let placeholderAttributes = AttributedStringBuilder()
            .with { builder in
                builder.typography = style.placeholder.typography
                builder.sizeCategory = .init(sizeCategory)
                builder.color = UIColor(style.placeholder.color)
            }
            .buildAttributes()
            .filter { Constants.includedTextAttributes.contains($0.key) }
        let updatedPlaceholder = NSAttributedString(string: prompt, attributes: placeholderAttributes)
        if textField.attributedPlaceholder != updatedPlaceholder {
            textField.attributedPlaceholder = updatedPlaceholder
        }
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

private final class TextField: UITextField {

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        if #available(iOS 16, *) {
            super.intrinsicContentSize
        } else {
            // On iOS < 16, SwiftUI framework sometimes ignores content hugging priority and shrinks view to its
            // intrinsic size. This is undesired because makes TextField hard to select especially when placeholder is
            // not set. Solution is to hardcode width to container width (set from parent via preferredWidth property).
            CGSize(width: preferredWidth, height: super.intrinsicContentSize.height)
        }
    }

    var preferredWidth: CGFloat = 0 {
        didSet { didChangePreferredWidth() }
    }

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        adjustsFontForContentSizeCategory = false
    }

    private func didChangePreferredWidth() {
        guard #unavailable(iOS 16) else {
            return
        }
        invalidateIntrinsicContentSize()
    }
}
