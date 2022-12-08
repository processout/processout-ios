//
//  NativeAlternativePaymentMethodSuccessView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.12.2022.
//

import UIKit

final class NativeAlternativePaymentMethodSuccessView: UIView {

    init(style: NativeAlternativePaymentMethodSuccessViewStyle) {
        self.style = style
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with state: NativeAlternativePaymentMethodViewModelState.Success, animated: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            CATransaction.begin()
            CATransaction.setDisableActions(!animated)
            if let image = state.gatewayLogo {
                iconImageView.image = image
                iconWidthConstraint?.isActive = false
                iconWidthConstraint = iconImageView.widthAnchor.constraint(
                    equalTo: iconImageView.heightAnchor, multiplier: image.size.width / image.size.height
                )
                iconWidthConstraint?.isActive = true
                iconImageView.setHidden(false)
            } else {
                iconImageView.setHidden(true)
            }
            descriptionLabel.attributedText = AttributedStringBuilder()
                .typography(style.message.typography)
                .textColor(style.message.color)
                .alignment(.center)
                .string(state.message)
                .build()
            setNeedsLayout()
            layoutIfNeeded()
            CATransaction.commit()
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let animationDuration: TimeInterval = 0.25
        static let iconHeight: CGFloat = 32
        static let verticalSpacing: CGFloat = 16
        static let descriptionBottomSpacing: CGFloat = 48
        static let topContentInset: CGFloat = 30
        static let minimumHorizontalContentInset: CGFloat = 24
    }

    // MARK: - Private Properties

    private let style: NativeAlternativePaymentMethodSuccessViewStyle

    private lazy var containerView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [iconImageView, descriptionLabel, decorationImageView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = Constants.verticalSpacing
        view.axis = .vertical
        view.alignment = .center
        view.setCustomSpacing(Constants.descriptionBottomSpacing, after: descriptionLabel)
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
        imageView.image = Asset.Images.success.image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        return imageView
    }()

    private var iconWidthConstraint: NSLayoutConstraint?

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        let constraints = [
            containerView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.topContentInset
            ),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor, constant: Constants.minimumHorizontalContentInset
            ),
            containerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            iconImageView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.iconHeight)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
