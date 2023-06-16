//
//  NativeAlternativePaymentMethodTitleCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.04.2023.
//

import UIKit

final class NativeAlternativePaymentMethodTitleCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(item: NativeAlternativePaymentMethodViewModelState.TitleItem, style: POTextStyle) {
        titleLabel.attributedText = AttributedStringBuilder()
            .typography(style.typography, style: .largeTitle)
            .alignment(.natural)
            .lineBreakMode(.byWordWrapping)
            .textColor(style.color)
            .string(item.text)
            .build()
    }

    // MARK: - Private Properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    // MARK: - Private Methods

    private func commonInit() {
        contentView.addSubview(titleLabel)
        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).with(priority: .defaultHigh),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
