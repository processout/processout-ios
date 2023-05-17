//
//  Button.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.11.2022.
//

import UIKit

final class Button: UIControl {

    struct ViewModel {

        /// Button's title.
        let title: String

        /// Boolean flag indicating whether button should display loading indicator.
        let isLoading: Bool

        /// Action handler.
        let handler: () -> Void
    }

    // MARK: -

    init(style: POButtonStyle) {
        self.style = style
        _isEnabled = true
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: ViewModel, isEnabled: Bool, animated: Bool) {
        UIView.perform(withAnimation: animated, duration: Constants.animationDuration) { [self] in
            let currentStyle = style(isEnabled: isEnabled, isHighlighted: isHighlighted)
            if viewModel.isLoading {
                titleLabel.alpha = 0
                activityIndicatorView.alpha = 1
            } else {
                let currentAttributedText = titleLabel.attributedText
                titleLabel.attributedText = AttributedStringBuilder()
                    .typography(currentStyle.title.typography)
                    .textStyle(textStyle: .body)
                    .maximumFontSize(Constants.maximumFontSize)
                    .textColor(currentStyle.title.color)
                    .alignment(.center)
                    .string(viewModel.title)
                    .build()
                titleLabel.alpha = 1
                if animated, currentAttributedText != titleLabel.attributedText {
                    titleLabel.addTransitionAnimation()
                }
                activityIndicatorView.alpha = 0
            }
            apply(style: currentStyle.border)
            apply(style: currentStyle.shadow)
            backgroundColor = currentStyle.backgroundColor
            UIView.performWithoutAnimation(layoutIfNeeded)
        }
        _isEnabled = isEnabled
        currentViewModel = viewModel
        if isEnabled {
            accessibilityTraits = [.button]
        } else {
            accessibilityTraits = [.button, .notEnabled]
        }
        accessibilityLabel = viewModel.title
    }

    func setEnabled(_ enabled: Bool, animated: Bool) {
        _isEnabled = enabled
        configureWithCurrentViewModel(animated: animated)
    }

    override var isEnabled: Bool {
        get { _isEnabled }
        set { setEnabled(newValue, animated: false) }
    }

    override var isHighlighted: Bool {
        didSet { configureWithCurrentViewModel(animated: true) }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let currentViewModel, currentViewModel.isLoading {
            return nil
        }
        return super.hitTest(point, with: event)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.isColorAppearanceDifferent(to: previousTraitCollection) {
            let style = style(isEnabled: isEnabled, isHighlighted: isHighlighted)
            layer.borderColor = style.border.color.cgColor
            layer.shadowColor = style.shadow.color.cgColor
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let height: CGFloat = 48
        static let minimumEdgesSpacing: CGFloat = 4
        static let maximumFontSize: CGFloat = 32
        static let animationDuration: TimeInterval = 0.25
    }

    // MARK: - Private Properties

    private let style: POButtonStyle

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.alpha = 0
        return label
    }()

    private lazy var activityIndicatorView: POActivityIndicatorView = {
        let view = ActivityIndicatorViewFactory().create(style: style.activityIndicator)
        view.hidesWhenStopped = false
        view.setAnimating(true)
        view.alpha = 0
        return view
    }()

    private var currentViewModel: ViewModel?
    private var _isEnabled: Bool

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(activityIndicatorView)
        let constraints = [
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor, constant: Constants.minimumEdgesSpacing
            ),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicatorView.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor, constant: Constants.minimumEdgesSpacing
            ),
            activityIndicatorView.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor, constant: Constants.minimumEdgesSpacing
            ),
            heightAnchor.constraint(equalToConstant: Constants.height)
        ]
        NSLayoutConstraint.activate(constraints)
        addTarget(self, action: #selector(didTouchUpInside), for: .touchUpInside)
        isAccessibilityElement = true
    }

    private func configureWithCurrentViewModel(animated: Bool) {
        if let currentViewModel {
            configure(viewModel: currentViewModel, isEnabled: isEnabled, animated: animated)
        }
    }

    private func style(isEnabled: Bool, isHighlighted: Bool) -> POButtonStateStyle {
        if !isEnabled {
            return style.disabled
        }
        if isHighlighted {
            return style.highlighted
        }
        return style.normal
    }

    // MARK: - Actions

    @objc
    private func didTouchUpInside() {
        currentViewModel?.handler()
    }
}
