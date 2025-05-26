//
//  TextFieldCoordinator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.01.2025.
//

import SwiftUI

@available(iOS 14, *)
final class TextFieldCoordinator: NSObject, TextFieldDelegate {

    init(
        text: Binding<String>,
        formatter: Formatter?,
        focusableView: Binding<FocusableViewProxy>,
        submitAction: POBackport<Any>.SubmitAction,
        editingWillChangeAction: TextFieldEditingWillChangeAction
    ) {
        self.text = text
        self.formatter = formatter
        self.focusableView = focusableView
        self.submitAction = submitAction
        self.editingWillChangeAction = editingWillChangeAction
    }

    /// The text value bound to the text field.
    var text: Binding<String>

    /// Optional formatter for input/output conversion.
    var formatter: Formatter?

    /// Binding to control or observe focusable view behavior.
    var focusableView: Binding<FocusableViewProxy>

    /// Action to perform when the text field is submitted (e.g., on return key).
    var submitAction: POBackport<Any>.SubmitAction

    /// Called when text field editing state is about to change.
    var editingWillChangeAction: TextFieldEditingWillChangeAction

    func mantle(textField: UITextField) {
        textField.delegate = self
        textField.addTarget(self, action: #selector(editingChanged(textField:)), for: .editingChanged)
    }

    func dismantle(textField: UITextField) {
        textField.delegate = nil
        textField.removeTarget(nil, action: nil, for: .allEvents)
    }

    // MARK: - UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateFocusableViewProxy(with: textField)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submitAction()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateFocusableViewProxy(with: textField)
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let formatter = formatter else {
            return true
        }
        // swiftlint:disable legacy_objc_type
        let originalString = (textField.text ?? "") as NSString
        var updatedString = originalString.replacingCharacters(in: range, with: string) as NSString
        // swiftlint:enable legacy_objc_type
        var proposedSelectedRange = NSRange(location: updatedString.length, length: 0)
        editingWillChangeAction(newValue: updatedString as String)
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

    func textField(_ textField: UITextField, didMoveToWindow window: UIWindow?) {
        updateFocusableViewProxy(with: textField)
    }

    // MARK: - Target Actions

    @objc private func editingChanged(textField: UITextField) {
        text.wrappedValue = textField.text ?? ""
    }

    // MARK: - Private Methods

    private func updateFocusableViewProxy(with textField: UITextField) {
        if textField.window == nil {
            focusableView.wrappedValue = .init()
        } else {
            focusableView.wrappedValue = .init(uiControl: textField)
        }
    }
}
