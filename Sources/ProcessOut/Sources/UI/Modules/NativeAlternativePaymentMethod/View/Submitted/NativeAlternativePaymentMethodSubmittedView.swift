//
//  NativeAlternativePaymentMethodSubmittedView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.12.2022.
//

import UIKit

final class NativeAlternativePaymentMethodSubmittedView: UIView {

    init(style: NativeAlternativePaymentMethodSubmittedViewStyle) {
        self.style = style
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with state: NativeAlternativePaymentMethodViewModelState.Submitted, animated: Bool) {
        if let image = state.logoImage {
            iconImageView.image = image
            iconImageView.setAspectRatio(image.size.width / image.size.height)
            iconImageViewWidthConstraint.constant = image.size.width
            iconImageView.setHidden(false)
        } else {
            iconImageView.setHidden(true)
        }
        let descriptionStyle: POTextStyle
        if state.isCaptured {
            descriptionStyle = style.successMessage
            descriptionLabel.accessibilityIdentifier = "native-alternative-payment.captured.description"
        } else {
            descriptionStyle = style.message
            descriptionLabel.accessibilityIdentifier = "native-alternative-payment.non-captured.description"
        }
        descriptionLabel.attributedText = AttributedStringBuilder()
            .typography(descriptionStyle.typography)
            .textStyle(textStyle: .headline)
            .textColor(descriptionStyle.color)
            .alignment(.center)
            .string(state.message)
            .build()
        if let image = state.image {
            decorationImageView.image = image
            decorationImageView.setAspectRatio(image.size.width / image.size.height)
            decorationImageViewWidthConstraint.constant = image.size.width
            decorationImageView.setHidden(false)
        } else {
            decorationImageView.setHidden(true)
        }
        containerView.setCustomSpacing(
            state.isCaptured ? Constants.descriptionBottomSpacing : Constants.descriptionBottomSmallSpacing,
            after: descriptionLabel
        )
        if animated {
            UIView.animate(withDuration: Constants.animationDuration) { self.addTransitionAnimation() }
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let animationDuration: TimeInterval = 0.25
        static let maximumHeight: CGFloat = 394
        static let maximumLogoImageHeight: CGFloat = 32
        static let maximumDecorationImageHeight: CGFloat = 260
        static let verticalSpacing: CGFloat = 16
        static let descriptionBottomSpacing: CGFloat = 46
        static let descriptionBottomSmallSpacing: CGFloat = 40
        static let verticalContentInset: CGFloat = 30
        static let horizontalContentInset: CGFloat = 24
    }

    // MARK: - Private Properties

    private let style: NativeAlternativePaymentMethodSubmittedViewStyle

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

    private lazy var iconImageViewWidthConstraint: NSLayoutConstraint = {
        iconImageView.widthAnchor.constraint(equalToConstant: 0).with(priority: .defaultHigh)
    }()

    private lazy var decorationImageViewWidthConstraint: NSLayoutConstraint = {
        decorationImageView.widthAnchor.constraint(equalToConstant: 0).with(priority: .defaultHigh)
    }()

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        let constraints = [
            containerView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.verticalContentInset
            ),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: Constants.horizontalContentInset
            ),
            containerView.bottomAnchor.constraint(
                lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.verticalContentInset
            ),
            containerView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.maximumHeight),
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
