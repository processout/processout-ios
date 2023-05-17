//
//  NativeAlternativePaymentMethodInputCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.04.2023.
//

import UIKit

final class NativeAlternativePaymentMethodInputCell: UICollectionViewCell, NativeAlternativePaymentMethodCell {

    override init(frame: CGRect) {
        observations = []
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        item = nil
        observations = []
    }

    func configure(item: NativeAlternativePaymentMethodViewModelState.InputItem, style: POInputFormStyle?) {
        let style = style ?? Constants.defaultStyle
        textFieldContainer.configure(
            style: item.value.isInvalid ? style.error.field : style.normal.field,
            animated: false
        )
        let textField = textFieldContainer.textField
        if textField.text != item.value.text {
            textField.text = item.value.text
        }
        textField.placeholder = item.placeholder
        textField.returnKeyType = item.isLast ? .done : .next
        textField.keyboardType = keyboardType(parameterType: item.type)
        textField.textContentType = textContentType(parameterType: item.type)
        observeChanges(item: item, style: style)
        self.item = item
    }

    // MARK: - NativeAlternativePaymentMethodCell

    var inputResponder: UIResponder? {
        textFieldContainer.textField
    }

    weak var delegate: NativeAlternativePaymentMethodCellDelegate?

    // MARK: - Private Nested Types

    private enum Constants {
        static let defaultStyle = POInputFormStyle.default
        static let accessibilityIdentifier = "native-alternative-payment.generic-input"
    }

    // MARK: - Private Properties

    private lazy var textFieldContainer: TextFieldContainerView = {
        let view = TextFieldContainerView()
        view.textField.accessibilityIdentifier = Constants.accessibilityIdentifier
        view.textField.delegate = self
        view.textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        return view
    }()

    private var item: NativeAlternativePaymentMethodViewModelState.InputItem?
    private var observations: [AnyObject]

    // MARK: - Private Methods

    private func commonInit() {
        contentView.addSubview(textFieldContainer)
        let constraints = [
            textFieldContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textFieldContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textFieldContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func keyboardType(
        parameterType: NativeAlternativePaymentMethodViewModelState.ParameterType
    ) -> UIKeyboardType {
        let keyboardTypes: [NativeAlternativePaymentMethodViewModelState.ParameterType: UIKeyboardType] = [
            .text: .asciiCapable, .email: .emailAddress, .numeric: .numberPad, .phone: .phonePad
        ]
        return keyboardTypes[parameterType] ?? .default
    }

    private func textContentType(
        parameterType: NativeAlternativePaymentMethodViewModelState.ParameterType
    ) -> UITextContentType? {
        let contentTypes: [NativeAlternativePaymentMethodViewModelState.ParameterType: UITextContentType] = [
            .email: .emailAddress, .numeric: .oneTimeCode, .phone: .telephoneNumber
        ]
        return contentTypes[parameterType]
    }

    @objc
    private func textFieldEditingChanged() {
        item?.value.text = textFieldContainer.textField.text ?? ""
    }

    private func observeChanges(
        item: NativeAlternativePaymentMethodViewModelState.InputItem, style: POInputFormStyle
    ) {
        let isInvalidObserver = item.value.$isInvalid.addObserver { [weak self] isInvalid in
            self?.textFieldContainer.configure(
                style: isInvalid ? style.error.field : style.normal.field, animated: true
            )
        }
        let valueObserver = item.value.$text.addObserver { [weak self] updatedValue in
            if self?.textFieldContainer.textField.text != updatedValue {
                self?.textFieldContainer.textField.text = updatedValue
            }
        }
        self.observations = [isInvalidObserver, valueObserver]
    }
}

extension NativeAlternativePaymentMethodInputCell: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        item?.value.isEditingAllowed ?? false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.nativeAlternativePaymentMethodCellShouldReturn(self) ?? true
    }

    func textField(
        _ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String
    ) -> Bool {
        guard let formatter = item?.formatter else {
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
}
