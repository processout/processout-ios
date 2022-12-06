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
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: ViewModel, animated: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            CATransaction.begin()
            CATransaction.setDisableActions(!animated)
            activityIndicatorView.alpha = viewModel.isLoading ? 1 : 0
            let currentStyle = self.currentStyle
            if viewModel.isLoading {
                titleLabel.alpha = 0
            } else {
                let currentAttributedText = titleLabel.attributedText
                titleLabel.attributedText = AttributedStringBuilder()
                    .typography(currentStyle.title.typography)
                    .maximumFontSize(Constants.maximumFontSize)
                    .textColor(currentStyle.title.color)
                    .string(viewModel.title)
                    .build()
                titleLabel.alpha = 1
                if animated, currentAttributedText != titleLabel.attributedText {
                    addTitleLabelTransition()
                }
            }
            apply(style: currentStyle.border)
            apply(style: currentStyle.shadow)
            backgroundColor = currentStyle.backgroundColor
            CATransaction.commit()
        }
        currentViewModel = viewModel
    }

    override var isEnabled: Bool {
        didSet { configureWithCurrentViewModel(animated: true) }
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

    // MARK: - Private Nested Types

    private enum Constants {
        static let height: CGFloat = 48
        static let minimumEdgesSpacing: CGFloat = 4
        static let maximumFontSize: CGFloat = 32
        static let animationDuration: TimeInterval = 0.2
    }

    // MARK: - Private Properties

    private let style: POButtonStyle

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var activityIndicatorView: POActivityIndicatorViewType = {
        let view: POActivityIndicatorViewType
        switch style.activityIndicator {
        case .custom(let customView):
            view = customView
        case let .system(style, color):
            let indicatorView = UIActivityIndicatorView(style: style)
            indicatorView.color = color
            view = indicatorView
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = false
        view.setAnimating(true)
        return view
    }()

    /// Style that is valid for current control's state.
    private var currentStyle: POButtonStateStyle {
        if !isEnabled {
            return style.disabled
        }
        if isHighlighted {
            return style.highlighted
        }
        return style.normal
    }

    private var currentViewModel: ViewModel?

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
        clipsToBounds = true
        addTarget(self, action: #selector(didTouchUpInside), for: .touchUpInside)
    }

    private func configureWithCurrentViewModel(animated: Bool) {
        guard let currentViewModel else {
            return
        }
        configure(viewModel: currentViewModel, animated: animated)
    }

    private func addTitleLabelTransition() {
        let transition = CATransition()
        transition.type = .fade
        if let backgroundAnimation = layer.action(forKey: "backgroundColor") as? CAAnimation {
            transition.duration = backgroundAnimation.duration
            transition.timingFunction = backgroundAnimation.timingFunction
        }
        titleLabel.layer.add(transition, forKey: "transition")
    }

    // MARK: - Actions

    @objc
    private func didTouchUpInside() {
        currentViewModel?.handler()
    }
}
