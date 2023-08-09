//
//  CollectionViewTitleCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.07.2023.
//

import UIKit

final class CollectionViewTitleCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: CollectionViewTitleViewModel, style: POTextStyle) {
        titleLabel.attributedText = AttributedStringBuilder()
            .with { builder in
                builder.typography = style.typography
                builder.textStyle = .largeTitle
                builder.lineBreakMode = .byWordWrapping
                builder.color = style.color
                builder.text = .plain(viewModel.text)
            }
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
