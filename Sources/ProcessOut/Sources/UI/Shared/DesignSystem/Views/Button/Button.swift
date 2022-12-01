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
        if animated {
            let options: UIView.AnimationOptions = [
                .beginFromCurrentState, .curveEaseOut, .allowAnimatedContent, .transitionCrossDissolve
            ]
            UIView.transition(
                with: self,
                duration: Constants.animationDuration,
                options: options,
                animations: {
                    self.configure(state: viewModel)
                },
                completion: nil
            )
        } else {
            UIView.performWithoutAnimation {
                configure(state: viewModel)
            }
        }
        currentViewModel = viewModel
    }

    override var isEnabled: Bool {
        didSet { configureWithCurrentViewModel() }
    }

    override var isHighlighted: Bool {
        didSet { configureWithCurrentViewModel() }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureWithCurrentViewModel(animated: false)
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
        case .system(let style):
            let indicatorView = UIActivityIndicatorView(style: style)
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

    private func configure(state: ViewModel) {
        activityIndicatorView.isHidden = !state.isLoading
        let currentStyle = self.currentStyle
        if state.isLoading {
            titleLabel.isHidden = true
        } else {
            titleLabel.attributedText = AttributedStringBuilder()
                .typography(currentStyle.title.typography)
                .maximumFontSize(Constants.maximumFontSize)
                .textColor(currentStyle.title.color)
                .string(state.title)
                .build()
            titleLabel.isHidden = false
        }
        apply(style: currentStyle.border)
        apply(style: currentStyle.shadow)
        backgroundColor = currentStyle.backgroundColor
    }

    private func configureWithCurrentViewModel(animated: Bool = true) {
        guard let currentViewModel else {
            return
        }
        configure(viewModel: currentViewModel, animated: true)
    }

    // MARK: - Actions

    @objc
    private func didTouchUpInside() {
        currentViewModel?.handler()
    }
}
