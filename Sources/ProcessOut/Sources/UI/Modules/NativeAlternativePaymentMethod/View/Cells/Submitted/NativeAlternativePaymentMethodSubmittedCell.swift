//
//  NativeAlternativePaymentMethodSubmittedCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.04.2023.
//

import UIKit

@available(*, deprecated)
final class NativeAlternativePaymentMethodSubmittedCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // swiftlint:disable:next function_body_length
    func configure(
        item: NativeAlternativePaymentMethodViewModelState.SubmittedItem,
        style: NativeAlternativePaymentMethodSubmittedCellStyle
    ) {
        let isMessageCompact = item.message.count <= Constants.maximumCompactMessageLength
        if isMessageCompact {
            containerViewTopConstraint.constant = Constants.topContentInset
        } else {
            containerViewTopConstraint.constant = Constants.compactTopContentInset
        }
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
                builder.alignment = isMessageCompact ? .center : .natural
                builder.text = .markdown(item.message)
            }
            .build()
        if let title = item.title {
            titleLabel.attributedText = AttributedStringBuilder()
                .with { builder in
                    builder.typography = style.title.typography
                    builder.textStyle = .largeTitle
                    builder.alignment = .center
                    builder.lineBreakMode = .byWordWrapping
                    builder.color = descriptionStyle.color
                    builder.text = .plain(title)
                }
                .build()
            titleLabel.setHidden(false)
        } else {
            titleLabel.setHidden(true)
        }
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
        static let compactTopContentInset: CGFloat = 24
        static let maximumCompactMessageLength = 150
    }

    // MARK: - Private Properties

    private lazy var containerView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, iconImageView, descriptionTextView, decorationImageView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = Constants.verticalSpacing
        view.axis = .vertical
        view.alignment = .center
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
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

    private lazy var decorationImageViewWidthConstraint
        = decorationImageView.widthAnchor.constraint(equalToConstant: 0).with(priority: .defaultHigh)

    private lazy var containerViewTopConstraint
        = containerView.topAnchor.constraint(equalTo: contentView.topAnchor)

    // MARK: - Private Methods

    private func commonInit() {
        contentView.addSubview(containerView)
        let constraints = [
            containerViewTopConstraint,
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
