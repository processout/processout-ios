//
//  NativeAlternativePaymentMethodErrorCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 26.04.2023.
//

import UIKit

final class NativeAlternativePaymentMethodErrorCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(item: NativeAlternativePaymentMethodViewModelState.ErrorItem, style: POTextStyle) {
        descriptionLabel.attributedText = AttributedStringBuilder()
            .with { builder in
                builder.typography = style.typography
                builder.textStyle = .body
                builder.color = style.color
                builder.alignment = item.isCentered ? .center : .natural
                builder.text = .plain(item.description)
            }
            .build()
    }

    // MARK: - Private Properties

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    // MARK: - Private Methods

    private func commonInit() {
        contentView.addSubview(descriptionLabel)
        let constraints = [
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            descriptionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
