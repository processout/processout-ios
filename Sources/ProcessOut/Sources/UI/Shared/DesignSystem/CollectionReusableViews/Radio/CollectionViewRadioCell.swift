//
//  CollectionViewRadioCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.08.2023.
//

import UIKit

final class CollectionViewRadioCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: CollectionViewRadioViewModel, style: PORadioButtonStyle) {
        let buttonViewModel = RadioButtonViewModel(
            isSelected: viewModel.isSelected, isInError: viewModel.isInvalid, value: viewModel.value
        )
        radioButton.configure(viewModel: buttonViewModel, style: style, animated: false)
        radioButton.accessibilityIdentifier = viewModel.accessibilityIdentifier
        self.viewModel = viewModel
    }

    // MARK: - Private Properties

    private lazy var radioButton: RadioButton = {
        let radioButton = RadioButton()
        radioButton.addTarget(self, action: #selector(didTouchRadioButton), for: .touchUpInside)
        return radioButton
    }()

    private var viewModel: CollectionViewRadioViewModel?

    // MARK: - Private Methods

    @objc private func didTouchRadioButton() {
        viewModel?.select()
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
