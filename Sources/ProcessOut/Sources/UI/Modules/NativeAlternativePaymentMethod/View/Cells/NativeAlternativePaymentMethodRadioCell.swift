//
//  NativeAlternativePaymentMethodRadioCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 06.06.2023.
//

import UIKit

final class NativeAlternativePaymentMethodRadioCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(item: NativeAlternativePaymentMethodViewModelState.RadioButtonItem, style: PORadioButtonStyle?) {
        let viewModel = RadioButtonViewModel(
            isSelected: item.isSelected, isInError: item.isInvalid, value: item.value
        )
        radioButton.configure(viewModel: viewModel, style: style ?? Constants.defaultStyle, animated: false)
        self.item = item
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let defaultStyle = PORadioButtonStyle.default
        static let accessibilityIdentifier = "native-alternative-payment.radio-button"
    }

    // MARK: - Private Properties

    private lazy var radioButton: RadioButton = {
        // todo(andrii-vysotskyi): test accessibility
        let radioButton = RadioButton()
        radioButton.addTarget(self, action: #selector(didTouchRadioButton), for: .touchUpInside)
        radioButton.accessibilityIdentifier = Constants.accessibilityIdentifier
        return radioButton
    }()

    private var item: NativeAlternativePaymentMethodViewModelState.RadioButtonItem?

    // MARK: - Private Methods

    @objc private func didTouchRadioButton() {
        item?.select()
    }

    private func commonInit() {
        contentView.addSubview(radioButton)
        let constraints = [
            radioButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            radioButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            radioButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            radioButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
