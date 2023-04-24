//
//  Picker.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.04.2023.
//

import UIKit

// todo: add icon
final class Picker: UIControl {

    init(style: POPickerStyle) {
        self.style = style
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: PickerViewModel, animated: Bool) {
        UIView.perform(withAnimation: animated, duration: Constants.animationDuration) { [self] in
            let currentStyle = style(isHighlighted: isHighlighted)
            let currentAttributedText = titleLabel.attributedText
            titleLabel.attributedText = AttributedStringBuilder()
                .typography(currentStyle.title.typography)
                .textStyle(textStyle: .body)
                .maximumFontSize(Constants.maximumFontSize)
                .textColor(currentStyle.title.color)
                .alignment(.center)
                .string(viewModel.title)
                .build()
            if animated, currentAttributedText != titleLabel.attributedText {
                titleLabel.addTransitionAnimation()
            }
            apply(style: currentStyle.border)
            apply(style: currentStyle.shadow)
            backgroundColor = currentStyle.backgroundColor
            UIView.performWithoutAnimation(layoutIfNeeded)
        }
        currentViewModel = viewModel
        accessibilityLabel = viewModel.title
    }

    override var isHighlighted: Bool {
        didSet { configureWithCurrentViewModel(animated: true) }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.isColorAppearanceDifferent(to: previousTraitCollection) {
            let style = style(isHighlighted: isHighlighted)
            layer.borderColor = style.border.color.cgColor
            layer.shadowColor = style.shadow.color.cgColor
        }
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
        static let height: CGFloat = 48
        static let minimumEdgesSpacing: CGFloat = 4
        static let maximumFontSize: CGFloat = 32
        static let animationDuration: TimeInterval = 0.25
    }

    // MARK: - Private Properties

    private let style: POPickerStyle

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private var currentViewModel: PickerViewModel?

    // MARK: - Private Methods

    private func commonInit() {
        accessibilityTraits = [.button]
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.minimumEdgesSpacing),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor, constant: Constants.minimumEdgesSpacing
            ),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
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

    private func configureWithCurrentViewModel(animated: Bool) {
        if let currentViewModel {
            configure(viewModel: currentViewModel, animated: animated)
        }
    }

    private func style(isHighlighted: Bool) -> POPickerStateStyle {
        isHighlighted ? style.highlighted : style.normal
    }

    // MARK: - Actions

    @objc
    private func didTouchUpInside() {
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
        var viewController: UIViewController?
        while next != nil {
            if let nextViewController = next as? UIViewController {
                viewController = nextViewController
                break
            }
        }
        guard let viewController else {
            return
        }
        viewController.present(viewController, animated: true)
    }
}
