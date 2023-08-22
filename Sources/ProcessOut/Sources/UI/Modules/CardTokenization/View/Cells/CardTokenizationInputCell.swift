//
//  CardTokenizationInputCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.07.2023.
//

import UIKit

final class CardTokenizationInputCell: UICollectionViewCell, CardTokenizationCell {

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

    func configure(item: CardTokenizationViewModelState.InputItem, style: POInputStyle) {
        textFieldContainer.configure(isInvalid: item.value.isInvalid, style: style, animated: false)
        let textField = textFieldContainer.textField
        if textField.text != item.value.text {
            textField.text = item.value.text
        }
        textField.placeholder = item.placeholder
        textField.keyboardType = item.keyboard
        textField.textContentType = item.contentType
        setTextFieldIcon(item.value.icon)
        self.item = item
        self.style = style
    }

    // MARK: - CardTokenizationCell

    func willDisplay() {
        observeItemChanges()
        updateFirstResponder()
    }

    func didEndDisplaying() {
        observations = []
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let accessibilityIdentifier = "card-tokenization.generic-input"
    }

    // MARK: - Private Properties

    private lazy var textFieldContainer: TextFieldContainerView = {
        let view = TextFieldContainerView()
        // todo(andrii-vysotskyi): make accessibility identifier dynamic
        view.textField.accessibilityIdentifier = Constants.accessibilityIdentifier
        view.textField.delegate = self
        view.textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        return view
    }()

    private var item: CardTokenizationViewModelState.InputItem?
    private var style: POInputStyle?
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

    @objc
    private func textFieldEditingChanged() {
        item?.value.text = textFieldContainer.textField.text ?? ""
    }

    private func observeItemChanges() {
        guard let item, let style else {
            return
        }
        let isInvalidObserver = item.value.$isInvalid.addObserver { [weak self] isInvalid in
            self?.textFieldContainer.configure(isInvalid: isInvalid, style: style, animated: true)
        }
        let valueObserver = item.value.$text.addObserver { [weak self] updatedValue in
            if self?.textFieldContainer.textField.text != updatedValue {
                self?.textFieldContainer.textField.text = updatedValue
            }
        }
        let activityObserver = item.value.$isFocused.addObserver { [weak self] _ in
            self?.updateFirstResponder()
        }
        let iconObserver = item.value.$icon.addObserver { [weak self] updatedIcon in
            self?.setTextFieldIcon(updatedIcon)
        }
        self.observations = [isInvalidObserver, valueObserver, activityObserver, iconObserver]
    }

    private func updateFirstResponder() {
        // Explicitly resigning responder and activating another causes the keyboard to jump. So implementation is
        // ignoring it. It is a responsibility of owning controller/collection to end editing when appropriate.
        let textField = textFieldContainer.textField
        guard let item, item.value.isFocused, !textField.isFirstResponder, window != nil else {
            return
        }
        textField.becomeFirstResponder()
    }

    private func setTextFieldIcon(_ image: UIImage?) {
        if let image {
            textFieldContainer.textField.rightView = UIImageView(image: image)
            textFieldContainer.textField.rightViewMode = .always
        } else {
            textFieldContainer.textField.rightViewMode = .never
        }
    }
}

extension CardTokenizationInputCell: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        item?.value.isFocused = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        item?.value.isFocused = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        item?.submit()
        return true
    }

    func textField(
        _ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String
    ) -> Bool {
        guard let formatter = item?.formatter else {
            return true
        }
        return TextFieldUtils.changeText(in: range, replacement: string, textField: textField, formatter: formatter)
    }
}
