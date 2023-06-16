//
//  NativeAlternativePaymentMethodSectionHeaderView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 26.04.2023.
//

import UIKit

final class NativeAlternativePaymentMethodSectionHeaderView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(item: NativeAlternativePaymentMethodViewModelState.SectionHeader, style: POTextStyle) {
        titleLabel.attributedText = AttributedStringBuilder()
            .typography(style.typography, style: .title3)
            .textColor(style.color)
            .alignment(item.isCentered ? .center : .natural)
            .string(item.title)
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
