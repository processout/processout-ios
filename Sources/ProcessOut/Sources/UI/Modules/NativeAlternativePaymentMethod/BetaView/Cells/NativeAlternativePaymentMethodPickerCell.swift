//
//  NativeAlternativePaymentMethodPickerCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.05.2023.
//

import UIKit

final class NativeAlternativePaymentMethodPickerCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(item: BetaNativeAlternativePaymentMethodViewModelState.PickerItem, style: POInputFormStyle?) {
        let options = item.options.map { option in
            PickerViewModel.Option(title: option.name, isSelected: option.isSelected, select: option.select)
        }
        picker.configure(
            viewModel: PickerViewModel(title: item.value, options: options),
            animated: false
        )
        let style = style ?? Constants.defaultStyle
        picker.configure(style: item.isInvalid ? style.error.field : style.normal.field, animated: false)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let defaultStyle = POInputFormStyle.default
        static let accessibilityIdentifier = "native-alternative-payment.picker"
    }

    // MARK: - Private Properties

    private lazy var picker: Picker = {
        let picker = Picker()
        picker.accessibilityIdentifier = Constants.accessibilityIdentifier
        return picker
    }()

    // MARK: - Private Methods

    private func commonInit() {
        contentView.addSubview(picker)
        let constraints = [
            picker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            picker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            picker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
