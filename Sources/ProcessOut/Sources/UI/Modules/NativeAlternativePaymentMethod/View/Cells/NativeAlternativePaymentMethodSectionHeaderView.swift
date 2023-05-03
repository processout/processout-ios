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

    func configure(item: NativeAlternativePaymentMethodViewModelState.SectionIdentifier, style: POTextStyle?) {
        let style = style ?? Constants.defaultStyle
        titleLabel.attributedText = AttributedStringBuilder()
            .typography(style.typography)
            .textStyle(textStyle: .body)
            .textColor(style.color)
            .alignment(.center)
            .string(item.title ?? "")
            .build()
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let defaultStyle = POTextStyle(color: Asset.Colors.Text.primary.color, typography: .bodyLarge)
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
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
