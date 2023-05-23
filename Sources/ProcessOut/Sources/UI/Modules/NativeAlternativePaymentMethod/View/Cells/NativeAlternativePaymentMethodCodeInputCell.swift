//
//  NativeAlternativePaymentMethodCodeInputCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 26.04.2023.
//

import UIKit

final class NativeAlternativePaymentMethodCodeInputCell: UICollectionViewCell, NativeAlternativePaymentMethodCell {

    override func prepareForReuse() {
        super.prepareForReuse()
        item = nil
        observations = []
    }

    func configure(item: NativeAlternativePaymentMethodViewModelState.CodeInputItem, style: POInputFormStyle?) {
        initialize(length: item.length)
        let style = style ?? Constants.defaultStyle
        codeTextField.configure(
            style: item.value.isInvalid ? style.error.field : style.normal.field,
            animated: false
        )
        if codeTextField.text != item.value.text {
            codeTextField.text = item.value.text
        }
        codeTextField.keyboardType = .numberPad
        codeTextField.textContentType = .oneTimeCode
        observeChanges(item: item, style: style)
        self.item = item
    }

    // MARK: - NativeAlternativePaymentMethodCell

    var inputResponder: UIResponder? {
        codeTextField
    }

    var delegate: NativeAlternativePaymentMethodCellDelegate?

    // MARK: - Private Nested Types

    private enum Constants {
        static let defaultStyle = POInputFormStyle.code
        static let accessibilityIdentifier = "native-alternative-payment.code-input"
    }

    // MARK: - Private Properties

    private var codeTextField: CodeTextField! // swiftlint:disable:this implicitly_unwrapped_optional
    private var item: NativeAlternativePaymentMethodViewModelState.CodeInputItem?
    private var observations: [AnyObject] = []

    // MARK: - Private Methods

    private func initialize(length: Int) {
        if let codeTextField, codeTextField.length == length {
            return
        }
        codeTextField?.removeFromSuperview()
        let codeTextField = CodeTextField(length: length)
        codeTextField.accessibilityIdentifier = Constants.accessibilityIdentifier
        codeTextField.delegate = self
        codeTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        contentView.addSubview(codeTextField)
        let constraints = [
            codeTextField.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            codeTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            codeTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        self.codeTextField = codeTextField
    }

    @objc
    private func textFieldEditingChanged() {
        item?.value.text = codeTextField.text ?? ""
    }

    private func observeChanges(
        item: NativeAlternativePaymentMethodViewModelState.CodeInputItem, style: POInputFormStyle
    ) {
        let isInvalidObserver = item.value.$isInvalid.addObserver { [weak self] isInvalid in
            self?.codeTextField.configure(
                style: isInvalid ? style.error.field : style.normal.field, animated: true
            )
        }
        let valueObserver = item.value.$text.addObserver { [weak self] updatedValue in
            if self?.codeTextField.text != updatedValue {
                self?.codeTextField.text = item.value.text
            }
        }
        self.observations = [isInvalidObserver, valueObserver]
    }
}

extension NativeAlternativePaymentMethodCodeInputCell: CodeTextFieldDelegate {

    func codeTextFieldShouldBeginEditing(_ textField: CodeTextField) -> Bool {
        item?.value.isEditingAllowed ?? false
    }

    func codeTextFieldShouldReturn(_ textField: CodeTextField) -> Bool {
        delegate?.nativeAlternativePaymentMethodCellShouldReturn(self) ?? true
    }
}
