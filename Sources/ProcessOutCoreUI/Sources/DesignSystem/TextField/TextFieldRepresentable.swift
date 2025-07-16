//
//  TextFieldRepresentable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.01.2025.
//

import SwiftUI

@available(iOS 14, *)
@MainActor
struct TextFieldRepresentable: UIViewRepresentable {

    init(text: Binding<String>, formatter: Formatter?, focusableView: Binding<FocusableViewProxy>) {
        self._text = text
        self.formatter = formatter
        self._focusableView = focusableView
    }

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> UITextField {
        let textField = TextField()
        textField.adjustsFontForContentSizeCategory = false
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        context.coordinator.mantle(textField: textField)
        return textField
    }

    func updateUIView(_ textField: UITextField, context: Context) {
        if #available(iOS 18.0, *) {
            context.animate {
                updateText(textField)
            }
        } else if context.transaction.animation != nil {
            UIView.animate(withDuration: Constants.animationDuration) {
                updateText(textField)
            }
        } else {
            updateText(textField)
        }
        textField.keyboardType = context.environment.poKeyboardType
        textField.textContentType = context.environment.poTextContentType
        textField.returnKeyType = context.environment.backportSubmitLabel.returnKeyType
        updateCoordinator(context.coordinator)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            text: $text,
            formatter: formatter,
            focusableView: $focusableView,
            submitAction: submitAction,
            editingDidChangeAction: editingDidChangeAction
        )
    }

    // swiftlint:disable:next identifier_name
    func _overrideSizeThatFits(_ size: inout CGSize, in proposedSize: _ProposedSize, uiView: UIViewType) {
        let proposal = POBackport<Any>.ProposedSize(proposedSize).replacingUnspecifiedDimensions(by: .zero)
        size = .init(width: proposal.width, height: uiView.font?.lineHeight ?? proposal.height)
    }

    @available(iOS 16, *)
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextField, context: Context) -> CGSize? {
        let proposal = proposal.replacingUnspecifiedDimensions(by: .zero)
        return .init(width: proposal.width, height: uiView.font?.lineHeight ?? proposal.height)
    }

    static func dismantleUIView(_ textField: UITextField, coordinator: TextFieldCoordinator) {
        coordinator.dismantle(textField: textField)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let animationDuration: TimeInterval = 0.25
    }

    // MARK: - Private Properties

    private let formatter: Formatter?

    @POBackport.ScaledMetric
    private var multiplier: CGFloat = 1.0

    @Environment(\.textStyle)
    private var textStyle

    @Environment(\.backportSubmitAction)
    private var submitAction

    @Environment(\.textFieldEditingDidChangeAction)
    private var editingDidChangeAction

    @Binding
    private var text: String

    @Binding
    private var focusableView: FocusableViewProxy

    // MARK: - Private Methods

    private func updateText(_ textField: UITextField) {
        if textField.text != text {
            textField.text = text
        }
        let multiplier = $multiplier.value(with: textStyle.typography.textStyle)
        textField.font = textStyle.typography.font.withSize(textStyle.typography.font.pointSize * multiplier)
        textField.textColor = UIColor(textStyle.color)
    }

    private func updateCoordinator(_ coordinator: TextFieldCoordinator) {
        coordinator.text = $text
        coordinator.formatter = formatter
        coordinator.focusableView = $focusableView
        coordinator.submitAction = submitAction
        coordinator.editingDidChangeAction = editingDidChangeAction
    }
}

// MARK: - UITextField

protocol TextFieldDelegate: UITextFieldDelegate {

    /// Tells the delegate that its window object changed.
    func textField(_ textField: UITextField, didMoveToWindow window: UIWindow?)
}

private final class TextField: UITextField {

    override func didMoveToWindow() {
        if let delegate = delegate as? TextFieldDelegate {
            delegate.textField(self, didMoveToWindow: window)
        }
        super.didMoveToWindow()
    }
}
