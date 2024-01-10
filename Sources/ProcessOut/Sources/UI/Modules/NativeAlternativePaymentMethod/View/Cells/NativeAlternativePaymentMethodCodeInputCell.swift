//
//  NativeAlternativePaymentMethodCodeInputCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 26.04.2023.
//

import UIKit

@available(*, deprecated)
final class NativeAlternativePaymentMethodCodeInputCell: UICollectionViewCell, NativeAlternativePaymentMethodCell {

    override func prepareForReuse() {
        super.prepareForReuse()
        item = nil
        observations = []
    }

    func configure(item: NativeAlternativePaymentMethodViewModelState.CodeInputItem, style: POInputStyle) {
        initialize(length: item.length)
        codeTextField.configure(isInvalid: item.value.isInvalid, style: style, animated: false)
        if codeTextField.text != item.value.text {
            codeTextField.text = item.value.text
        }
        codeTextField.keyboardType = .numberPad
        codeTextField.textContentType = .oneTimeCode
        codeTextFieldCenterXConstraint.isActive = item.isCentered
        self.item = item
        self.style = style
    }

    // MARK: - NativeAlternativePaymentMethodCell

    func willDisplay() {
        guard let item, let style else {
            return
        }
        let isInvalidObserver = item.value.$isInvalid.addObserver { [weak self] isInvalid in
            self?.codeTextField.configure(isInvalid: isInvalid, style: style, animated: true)
        }
        let valueObserver = item.value.$text.addObserver { [weak self] updatedValue in
            if self?.codeTextField.text != updatedValue {
                self?.codeTextField.text = item.value.text
            }
        }
        self.observations = [isInvalidObserver, valueObserver]
    }

    func didEndDisplaying() {
        observations = []
    }

    var inputResponder: UIResponder? {
        codeTextField
    }

    var delegate: NativeAlternativePaymentMethodCellDelegate?

    // MARK: - Private Nested Types

    private enum Constants {
        static let accessibilityIdentifier = "native-alternative-payment.code-input"
    }

    // MARK: - Private Properties

    // swiftlint:disable implicitly_unwrapped_optional
    private var codeTextField: CodeTextField!
    private var codeTextFieldCenterXConstraint: NSLayoutConstraint!
    // swiftlint:enable implicitly_unwrapped_optional

    private var item: NativeAlternativePaymentMethodViewModelState.CodeInputItem?
    private var style: POInputStyle?
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
            codeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).with(priority: .defaultHigh),
            codeTextField.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            codeTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        self.codeTextField = codeTextField
        // Center constraint is disabled by default
        self.codeTextFieldCenterXConstraint = codeTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
    }

    @objc
    private func textFieldEditingChanged() {
        item?.value.text = codeTextField.text ?? ""
    }
}

@available(*, deprecated)
extension NativeAlternativePaymentMethodCodeInputCell: CodeTextFieldDelegate {

    func codeTextFieldShouldBeginEditing(_ textField: CodeTextField) -> Bool {
        item?.value.isEditingAllowed ?? false
    }

    func codeTextFieldShouldReturn(_ textField: CodeTextField) -> Bool {
        delegate?.nativeAlternativePaymentMethodCellShouldReturn(self) ?? true
    }
}
