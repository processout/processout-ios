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
            descriptionStyle = style.successMessage
            descriptionTextView.accessibilityIdentifier = "native-alternative-payment.captured.description"
        } else {
            descriptionStyle = style.message
            descriptionTextView.accessibilityIdentifier = "native-alternative-payment.non-captured.description"
        }
        descriptionTextView.attributedText = AttributedStringBuilder()
            .with { builder in
                builder.typography = descriptionStyle.typography
                builder.textStyle = .body
                builder.color = descriptionStyle.color
                builder.lineBreakMode = .byWordWrapping
                builder.alignment =
                    item.message.count > Constants.maximumCenterAlignedMessageLength ? .natural : .center
                builder.text = .markdown(item.message)
            }
            .build()
        if let image = item.image {
            decorationImageView.image = image
            decorationImageView.tintColor = descriptionStyle.color
            decorationImageView.setAspectRatio(image.size.width / image.size.height)
            decorationImageViewWidthConstraint.constant = image.size.width
            decorationImageView.setHidden(false)
        } else {
            decorationImageView.setHidden(true)
        }
        containerView.setCustomSpacing(
            item.isCaptured ? Constants.descriptionBottomSpacing : Constants.descriptionBottomSmallSpacing,
            after: descriptionTextView
        )
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let maximumLogoImageHeight: CGFloat = 32
        static let maximumDecorationImageHeight: CGFloat = 260
        static let verticalSpacing: CGFloat = 16
        static let descriptionBottomSpacing: CGFloat = 46
        static let descriptionBottomSmallSpacing: CGFloat = 24
        static let topContentInset: CGFloat = 68
        static let maximumCenterAlignedMessageLength = 150
    }

    // MARK: - Private Properties

    private lazy var containerView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [iconImageView, descriptionTextView, decorationImageView])
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

    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentHuggingPriority(.required, for: .vertical)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.adjustsFontForContentSizeCategory = false
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = true
        return textView
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
        contentView.addSubview(containerView)
        let constraints = [
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topContentInset),
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).with(priority: .defaultHigh),
            iconImageView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.maximumLogoImageHeight),
            iconImageView.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor),
            iconImageViewWidthConstraint,
            descriptionTextView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            decorationImageView.heightAnchor.constraint(
                lessThanOrEqualToConstant: Constants.maximumDecorationImageHeight
            ),
            decorationImageView.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor),
            decorationImageViewWidthConstraint
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
