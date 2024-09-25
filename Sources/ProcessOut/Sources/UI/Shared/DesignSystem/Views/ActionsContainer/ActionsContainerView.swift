//
//  NativeAlternativePaymentMethodButtonsView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.02.2023.
//

import UIKit

@available(*, deprecated)
final class ActionsContainerView: UIView {

    init(style: POActionsContainerStyle, horizontalInset: CGFloat) {
        self.style = style
        self.horizontalInset = horizontalInset
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: ActionsContainerViewModel, animated: Bool) {
        if viewModel.primary != nil || viewModel.secondary != nil {
            let animated = animated && alpha > 0
            configure(button: primaryButton, viewModel: viewModel.primary, animated: animated)
            configure(button: secondaryButton, viewModel: viewModel.secondary, animated: animated)
            alpha = 1
        } else {
            alpha = 0
        }
    }

    func contentHeight(viewModel: ActionsContainerViewModel) -> CGFloat {
        guard viewModel.primary != nil || viewModel.secondary != nil else {
            return 0
        }
        let numberOfActions: Int
        switch style.axis {
        case .horizontal:
            numberOfActions = 1
        case .vertical:
            numberOfActions = [viewModel.primary, viewModel.secondary].compactMap { $0 }.count
        @unknown default:
            assertionFailure("Unexpected axis.")
            numberOfActions = 1
        }
        let buttonsHeight =
            Constants.buttonHeight * CGFloat(numberOfActions) +
            Constants.spacing * CGFloat(numberOfActions - 1)
        return Constants.verticalInset * 2 + buttonsHeight
    }

    var additionalBottomSafeAreaInset: CGFloat = 0 {
        didSet { bottomConstraint.constant = -(additionalBottomSafeAreaInset + Constants.verticalInset) }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let spacing: CGFloat = 16
        static let verticalInset: CGFloat = 16
        static let buttonHeight: CGFloat = 44
        static let separatorHeight: CGFloat = 1
    }

    // MARK: - Private Properties

    private let style: POActionsContainerStyle
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

    private lazy var primaryButton = Button(style: style.primary)
    private lazy var secondaryButton = Button(style: style.secondary)

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
            contentView.leadingAnchor
                .constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: horizontalInset)
                .with(priority: .defaultHigh),
            contentView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalInset),
            contentView.heightAnchor.constraint(equalToConstant: 0).with(priority: .defaultLow),
            bottomConstraint
        ]
        NSLayoutConstraint.activate(constraints)
        backgroundColor = style.backgroundColor
    }

    private func configure(button: Button, viewModel: ActionsContainerActionViewModel?, animated: Bool) {
        if let viewModel {
            let buttonViewModel = Button.ViewModel(
                title: viewModel.title, isLoading: viewModel.isExecuting, handler: viewModel.handler
            )
            button.configure(viewModel: buttonViewModel, isEnabled: viewModel.isEnabled, animated: animated)
            button.setHidden(false)
            button.alpha = 1
            button.accessibilityIdentifier = viewModel.accessibilityIdentifier
        } else {
            button.setHidden(true)
            button.alpha = 0
        }
    }
}
