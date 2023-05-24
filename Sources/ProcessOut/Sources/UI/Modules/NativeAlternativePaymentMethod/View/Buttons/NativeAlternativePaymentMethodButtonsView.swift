//
//  NativeAlternativePaymentMethodButtonsView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.02.2023.
//

import UIKit

final class NativeAlternativePaymentMethodButtonsView: UIView {

    init(style: PONativeAlternativePaymentMethodActionsStyle, horizontalInset: CGFloat) {
        self.style = style
        self.horizontalInset = horizontalInset
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(actions: NativeAlternativePaymentMethodViewModelState.Actions, animated: Bool) {
        if actions.primary != nil || actions.secondary != nil {
            let animated = animated && alpha > 0
            configure(button: primaryButton, withAction: actions.primary, animated: animated)
            configure(button: secondaryButton, withAction: actions.secondary, animated: animated)
            alpha = 1
        } else {
            alpha = 0
        }
    }

    func contentHeight(actions: NativeAlternativePaymentMethodViewModelState.Actions) -> CGFloat {
        guard actions.primary != nil || actions.secondary != nil else {
            return 0
        }
        let buttonsHeight: CGFloat
        switch style.axis {
        case .horizontal:
            buttonsHeight = Constants.buttonHeight
        case .vertical:
            let numberOfActions = [actions.primary, actions.secondary].compactMap { $0 }.count
            return CGFloat(numberOfActions) * Constants.buttonHeight + Constants.spacing * CGFloat(numberOfActions - 1)
        @unknown default:
            assertionFailure("Unexpected axis.")
            return 0
        }
        return Constants.verticalInset * 2 + buttonsHeight
    }

    var additionalBottomSafeAreaInset: CGFloat = 0 {
        didSet { bottomConstraint.constant = -(additionalBottomSafeAreaInset + Constants.verticalInset) }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let spacing: CGFloat = 16
        static let verticalInset: CGFloat = 16
        static let buttonHeight: CGFloat = 40
        static let separatorHeight: CGFloat = 1
    }

    // MARK: - Private Properties

    private let style: PONativeAlternativePaymentMethodActionsStyle
    private let horizontalInset: CGFloat

    private lazy var contentView: UIStackView = {
        var arrangedSubviews = [primaryButton, secondaryButton]
        if case .horizontal = style.axis {
            arrangedSubviews.reverse()
        }
        let view = UIStackView(arrangedSubviews: arrangedSubviews)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = Constants.spacing
        view.axis = style.axis
        view.distribution = .fillEqually
        return view
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = style.separatorColor
        return view
    }()

    private lazy var primaryButton: Button = {
        let button = Button(style: style.primary)
        button.accessibilityIdentifier = "native-alternative-payment.primary-button"
        return button
    }()

    private lazy var secondaryButton: Button = {
        let button = Button(style: style.secondary)
        button.accessibilityIdentifier = "native-alternative-payment.secondary-button"
        return button
    }()

    private lazy var bottomConstraint = contentView.bottomAnchor.constraint(
        equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.verticalInset
    )

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)
        addSubview(contentView)
        let constraints = [
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
            contentView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: horizontalInset),
            contentView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalInset),
            contentView.heightAnchor.constraint(equalToConstant: 0).with(priority: .defaultLow),
            bottomConstraint
        ]
        NSLayoutConstraint.activate(constraints)
        backgroundColor = style.backgroundColor
    }

    private func configure(
        button: Button, withAction action: NativeAlternativePaymentMethodViewModelState.Action?, animated: Bool
    ) {
        guard let action else {
            button.setHidden(true)
            button.alpha = 0
            return
        }
        let viewModel = Button.ViewModel(
            title: action.title, isLoading: action.isExecuting, handler: action.handler
        )
        button.configure(viewModel: viewModel, isEnabled: action.isEnabled, animated: animated)
        button.setHidden(false)
        button.alpha = 1
    }
}
