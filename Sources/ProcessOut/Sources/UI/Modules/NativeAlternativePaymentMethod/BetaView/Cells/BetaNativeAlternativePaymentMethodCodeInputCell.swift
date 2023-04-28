//
//  BetaNativeAlternativePaymentMethodCodeInputCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 26.04.2023.
//

import UIKit

final class BetaNativeAlternativePaymentMethodCodeInputCell:
    UICollectionViewCell, BetaNativeAlternativePaymentMethodCell {

    override func prepareForReuse() {
        super.prepareForReuse()
        observations = []
    }

    func configure(item: BetaNativeAlternativePaymentMethodViewModelState.CodeInputItem, style: POInputFormStyle?) {
        initialize(length: item.length)
        let style = style ?? Constants.defaultStyle
        codeTextField.configure(
            style: item.isInvalid ? style.error.field : style.normal.field,
            animated: false
        )
        if codeTextField.text != item.value {
            codeTextField.text = item.value
        }
        codeTextField.keyboardType = .numberPad
        codeTextField.textContentType = .oneTimeCode
        observeChanges(item: item, style: style)
        self.item = item
    }

    // MARK: - BetaNativeAlternativePaymentMethodCell

    var inputResponder: UIResponder? {
        codeTextField
    }

    var delegate: BetaNativeAlternativePaymentMethodCellDelegate?

    // MARK: - Private Nested Types

    private enum Constants {
        static let defaultStyle = POInputFormStyle.code
        static let accessibilityIdentifier = "native-alternative-payment.code-input"
    }

    // MARK: - Private Properties

    private var codeTextField: CodeTextField! // swiftlint:disable:this implicitly_unwrapped_optional
    private var item: BetaNativeAlternativePaymentMethodViewModelState.CodeInputItem?
    private var observations: [AnyObject] = []

    // MARK: - Private Methods

    private func initialize(length: Int) {
        if let item, item.length != length {
            codeTextField.removeFromSuperview()
        }
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
        item?.value = codeTextField.text ?? ""
    }

    private func observeChanges(
        item: BetaNativeAlternativePaymentMethodViewModelState.CodeInputItem, style: POInputFormStyle
    ) {
        let isInvalidObserver = item.$isInvalid.addObserver { [weak self] isInvalid in
            self?.codeTextField.configure(
                style: isInvalid ? style.error.field : style.normal.field, animated: true
            )
        }
        let valueObserver = item.$value.addObserver { [weak self] updatedValue in
            if self?.codeTextField.text != updatedValue {
                self?.codeTextField.text = item.value
            }
        }
        self.observations = [isInvalidObserver, valueObserver]
    }
}

extension BetaNativeAlternativePaymentMethodCodeInputCell: CodeTextFieldDelegate {

    func codeTextFieldShouldBeginEditing(_ textField: CodeTextField) -> Bool {
        item?.isEditingAllowed ?? false
    }

    func codeTextFieldShouldReturn(_ textField: CodeTextField) -> Bool {
        delegate?.nativeAlternativePaymentMethodCellShouldReturn(self) ?? true
    }
}
