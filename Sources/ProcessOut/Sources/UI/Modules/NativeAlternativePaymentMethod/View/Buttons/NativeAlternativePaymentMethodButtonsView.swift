//
//  NativeAlternativePaymentMethodButtonsView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.02.2023.
//

import UIKit

final class NativeAlternativePaymentMethodButtonsView: UIView {

    init(style: NativeAlternativePaymentMethodButtonsViewStyle, horizontalInset: CGFloat) {
        self.style = style
        self.horizontalInset = horizontalInset
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        primaryAction: NativeAlternativePaymentMethodViewModelState.Action,
        secondaryAction: NativeAlternativePaymentMethodViewModelState.Action?,
        animated: Bool
    ) {
        configure(button: primaryButton, action: primaryAction, animated: animated)
        if let secondaryAction {
            configure(button: secondaryButton, action: secondaryAction, animated: animated)
            secondaryButton.setHidden(false)
        } else {
            secondaryButton.setHidden(true)
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let spacing: CGFloat = 16
        static let verticalInset: CGFloat = 24
    }

    // MARK: - Private Properties

    private let style: NativeAlternativePaymentMethodButtonsViewStyle
    private let horizontalInset: CGFloat

    private lazy var contentView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [primaryButton, secondaryButton])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = Constants.spacing
        view.axis = .vertical
        return view
    }()

    private lazy var primaryButton: Button = {
        let button = Button(style: style.primaryButton)
        button.accessibilityIdentifier = "native-alternative-payment.primary-button"
        return button
    }()

    private lazy var secondaryButton: Button = {
        let button = Button(style: style.secondaryButton)
        button.accessibilityIdentifier = "native-alternative-payment.secondary-button"
        return button
    }()

    // MARK: - Private Methods

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        let constraints = [
            contentView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: horizontalInset),
            contentView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.verticalInset),
            contentView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func configure(
        button: Button, action: NativeAlternativePaymentMethodViewModelState.Action, animated: Bool
    ) {
        let viewModel = Button.ViewModel(title: action.title, isLoading: action.isExecuting, handler: action.handler)
        button.configure(viewModel: viewModel, isEnabled: action.isEnabled, animated: animated)
    }
}
