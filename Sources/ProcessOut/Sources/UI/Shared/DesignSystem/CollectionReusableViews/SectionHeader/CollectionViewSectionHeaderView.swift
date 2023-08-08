//
//  CollectionViewSectionHeaderView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.07.2023.
//

import UIKit

final class CollectionViewSectionHeaderView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(item: String, style: POTextStyle) {
        titleLabel.attributedText = AttributedStringBuilder()
            .with { builder in
                builder.typography = style.typography
                builder.textStyle = .title3
                builder.color = style.color
                builder.text = .plain(item)
            }
            .build()
    }

    // MARK: - Private Properties

    private lazy var titleLabel: UILabel = {
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
        addSubview(titleLabel)
        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).with(priority: .defaultHigh)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
