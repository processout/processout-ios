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
        observations = []
    }

    func configure(item: NativeAlternativePaymentMethodViewModelState.InputItem, style: POInputFormStyle?) {
        let style = style ?? Constants.defaultStyle
        textFieldContainer.configure(
            style: item.isInvalid ? style.error.field : style.normal.field,
            animated: false
        )
        let textField = textFieldContainer.textField
        if textField.text != item.value {
            textField.text = item.value
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
        item?.value = textFieldContainer.textField.text ?? ""
    }

    private func observeChanges(
        item: NativeAlternativePaymentMethodViewModelState.InputItem, style: POInputFormStyle
    ) {
        let isInvalidObserver = item.$isInvalid.addObserver { [weak self] isInvalid in
            self?.textFieldContainer.configure(
                style: isInvalid ? style.error.field : style.normal.field, animated: true
            )
        }
        let valueObserver = item.$value.addObserver { [weak self] updatedValue in
            if self?.textFieldContainer.textField.text != updatedValue {
                self?.textFieldContainer.textField.text = item.value
            }
        }
        self.observations = [isInvalidObserver, valueObserver]
    }
}

extension NativeAlternativePaymentMethodInputCell: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        item?.isEditingAllowed ?? false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.nativeAlternativePaymentMethodCellShouldReturn(self) ?? true
    }

    func textField(
        _ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String
    ) -> Bool {
        // swiftlint:disable:next legacy_objc_type
        let updatedText = (textField.text as? NSString)?.replacingCharacters(in: range, with: string)
        guard let updatedText, let item else {
            return true
        }
        let formattedText = item.formatted(updatedText)
        guard formattedText != updatedText else {
            return true
        }
        textField.text = formattedText
        textField.sendActions(for: .editingChanged)
        return false
    }
}
