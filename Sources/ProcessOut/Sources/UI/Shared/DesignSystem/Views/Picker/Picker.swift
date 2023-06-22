//
//  Picker.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.04.2023.
//

import UIKit

// todo(andrii-vysotskyi): add placeholder
final class Picker: UIControl {

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: PickerViewModel, style: POInputStyle, animated: Bool) {
        currentViewModel = viewModel
        currentStyle = viewModel.isInvalid ? style.error : style.normal
        configureWithCurrentState(animated: animated)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.isColorAppearanceDifferent(to: previousTraitCollection), let currentStyle else {
            return
        }
        layer.borderColor = currentStyle.border.color.cgColor
        layer.shadowColor = currentStyle.shadow.color.cgColor
    }

    // MARK: - UIContextMenuInteractionDelegate

    @available(iOS 14.0, *)
    override func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let currentViewModel else {
            return nil
        }
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let menuChildren = currentViewModel.options.map { option in
                UIAction(title: option.title, state: option.isSelected ? .on : .off) { _ in
                    option.select()
                }
            }
            return UIMenu(children: menuChildren)
        }
        return configuration
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let height: CGFloat = 44
        static let horizontalInset: CGFloat = 12
        static let maximumFontSize: CGFloat = 22
        static let animationDuration: TimeInterval = 0.25
    }

    // MARK: - Private Properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: Asset.Images.chevronDown.image.withRenderingMode(.alwaysTemplate))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()

    private var currentStyle: POInputStateStyle?
    private var currentViewModel: PickerViewModel?

    // MARK: - Private Methods

    private func commonInit() {
        accessibilityTraits = [.button]
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(iconImageView)
        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalInset),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(
                equalTo: iconImageView.leadingAnchor, constant: -Constants.horizontalInset
            ),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalInset),
            heightAnchor.constraint(equalToConstant: Constants.height)
        ]
        NSLayoutConstraint.activate(constraints)
        if #available(iOS 14, *) {
            showsMenuAsPrimaryAction = true
            isContextMenuInteractionEnabled = true
        } else {
            addTarget(self, action: #selector(didTouchUpInside), for: .touchUpInside)
        }
        isAccessibilityElement = true
    }

    private func configureWithCurrentState(animated: Bool) {
        guard let currentViewModel, let currentStyle else {
            return
        }
        UIView.perform(withAnimation: animated, duration: Constants.animationDuration) { [self] in
            let currentAttributedText = titleLabel.attributedText
            titleLabel.attributedText = AttributedStringBuilder()
                .typography(currentStyle.text.typography)
                .textStyle(textStyle: .body)
                .maximumFontSize(Constants.maximumFontSize)
                .textColor(currentStyle.text.color)
                .alignment(.natural)
                .string(currentViewModel.title)
                .build()
            if animated, currentAttributedText != titleLabel.attributedText {
                titleLabel.addTransitionAnimation()
            }
            apply(style: currentStyle.border)
            apply(style: currentStyle.shadow)
            iconImageView.tintColor = currentStyle.tintColor
            backgroundColor = currentStyle.backgroundColor
            UIView.performWithoutAnimation(layoutIfNeeded)
        }
        accessibilityLabel = currentViewModel.title
    }

    // MARK: - Actions

    @objc
    private func didTouchUpInside() {
        // Fallback for iOS < 14
        guard let currentViewModel else {
            return
        }
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for option in currentViewModel.options {
            let action = UIAlertAction(title: option.title, style: .default) { _ in
                option.select()
            }
            actionSheetController.addAction(action)
        }
        let viewController: UIViewController? = {
            var nextResponder = next
            while nextResponder != nil {
                if let viewController = nextResponder as? UIViewController {
                    return viewController
                }
                nextResponder = nextResponder?.next
            }
            return nil
        }()
        guard let viewController else {
            return
        }
        viewController.present(actionSheetController, animated: true)
    }
}
