//
//  NativeAlternativePaymentMethodSubmittedCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.04.2023.
//

import UIKit

final class NativeAlternativePaymentMethodSubmittedCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        item: NativeAlternativePaymentMethodViewModelState.SubmittedItem,
        style: NativeAlternativePaymentMethodSubmittedCellStyle
    ) {
        if let image = item.logoImage {
            iconImageView.image = image
            iconImageView.setAspectRatio(image.size.width / image.size.height)
            iconImageViewWidthConstraint.constant = image.size.width
            iconImageView.setHidden(false)
        } else {
            iconImageView.setHidden(true)
        }
        let descriptionStyle: POTextStyle
        if item.isCaptured {
            descriptionStyle = style.successMessage ?? Constants.defaultSuccessMessageStyle
            descriptionLabel.accessibilityIdentifier = "native-alternative-payment.captured.description"
        } else {
            descriptionStyle = style.message ?? Constants.defaultMessageStyle
            descriptionLabel.accessibilityIdentifier = "native-alternative-payment.non-captured.description"
        }
        descriptionLabel.attributedText = AttributedStringBuilder()
            .typography(descriptionStyle.typography)
            .textStyle(textStyle: .headline)
            .textColor(descriptionStyle.color)
            .alignment(.center)
            .string(item.message)
            .build()
        if let image = item.image {
            decorationImageView.image = image
            decorationImageView.setAspectRatio(image.size.width / image.size.height)
            decorationImageViewWidthConstraint.constant = image.size.width
            decorationImageView.setHidden(false)
        } else {
            decorationImageView.setHidden(true)
        }
        containerView.setCustomSpacing(
            item.isCaptured ? Constants.descriptionBottomSpacing : Constants.descriptionBottomSmallSpacing,
            after: descriptionLabel
        )
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let defaultMessageStyle = POTextStyle(color: Asset.Colors.Text.primary.color, typography: .headline)
        static let defaultSuccessMessageStyle = POTextStyle(
            color: Asset.Colors.Text.success.color, typography: .headline
        )
        static let maximumLogoImageHeight: CGFloat = 32
        static let maximumDecorationImageHeight: CGFloat = 260
        static let verticalSpacing: CGFloat = 16
        static let descriptionBottomSpacing: CGFloat = 46
        static let descriptionBottomSmallSpacing: CGFloat = 40
        static let topContentInset: CGFloat = 26
    }

    // MARK: - Private Properties

    private lazy var containerView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [iconImageView, descriptionLabel, decorationImageView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = Constants.verticalSpacing
        view.axis = .vertical
        view.alignment = .center
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.adjustsFontForContentSizeCategory = false
        return label
    }()

    private lazy var decorationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var iconImageViewWidthConstraint
        = iconImageView.widthAnchor.constraint(equalToConstant: 0).with(priority: .defaultHigh)

    private lazy var decorationImageViewWidthConstraint: NSLayoutConstraint
        = decorationImageView.widthAnchor.constraint(equalToConstant: 0).with(priority: .defaultHigh)

    // MARK: - Private Methods

    private func commonInit() {
        // adjust top and bottom spacing (take into account that there is already spacing added by collection
        contentView.addSubview(containerView)
        let constraints = [
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topContentInset),
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).with(priority: .defaultHigh),
            iconImageView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.maximumLogoImageHeight),
            iconImageView.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor),
            iconImageViewWidthConstraint,
            decorationImageView.heightAnchor.constraint(
                lessThanOrEqualToConstant: Constants.maximumDecorationImageHeight
            ),
            decorationImageView.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor),
            decorationImageViewWidthConstraint
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
