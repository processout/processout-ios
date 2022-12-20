//
//  NativeAlternativePaymentMethodViewController.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.10.2022.
//

import UIKit

final class NativeAlternativePaymentMethodViewController: UIViewController {

    init(
        viewModel: any NativeAlternativePaymentMethodViewModelType,
        customStyle: PONativeAlternativePaymentMethodStyle?
    ) {
        notificationObservers = []
        self.viewModel = viewModel
        self.customStyle = customStyle
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = Asset.Colors.Background.primary.color
        view.addSubview(startedView)
        view.addSubview(backgroundDecorationView)
        view.addSubview(activityIndicatorView)
        view.addSubview(submittedView)
        let constraints = [
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backgroundDecorationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundDecorationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundDecorationView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundDecorationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            startedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            startedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            startedView.topAnchor.constraint(equalTo: view.topAnchor),
            startedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            submittedView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            submittedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submittedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            submittedView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        self.view = view
        NSLayoutConstraint.activate(constraints)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        observeNotifications()
        viewModel.didChange = { [weak self] in self?.configureWithViewModelState(animated: true) }
        viewModel.start()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let animationDuration: TimeInterval = 0.25
    }

    // MARK: - Private Properties

    private let viewModel: any NativeAlternativePaymentMethodViewModelType
    private let customStyle: PONativeAlternativePaymentMethodStyle?

    private lazy var activityIndicatorView: POActivityIndicatorViewType = {
        let style: POActivityIndicatorStyle
        if #available(iOS 13.0, *) {
            style = customStyle?.activityIndicator ?? .system(.large, color: Asset.Colors.Generic.white.color)
        } else {
            style = customStyle?.activityIndicator ?? .system(.whiteLarge, color: Asset.Colors.Generic.white.color)
        }
        let view: POActivityIndicatorViewType
        switch style {
        case .custom(let customView):
            view = customView
        case let .system(style, color):
            let indicatorView = UIActivityIndicatorView(style: style)
            view = indicatorView
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = false
        view.setAnimating(true)
        return view
    }()

    private lazy var backgroundDecorationView: BackgroundDecorationView = {
        BackgroundDecorationView(style: customStyle?.backgroundDecoration ?? .default)
    }()

    private lazy var startedView: NativeAlternativePaymentMethodStartedView = {
        let style = NativeAlternativePaymentMethodStartedViewStyle(
            title: customStyle?.title ?? .init(color: Asset.Colors.Text.primary.color, typography: .title),
            input: customStyle?.input ?? .default,
            codeInput: customStyle?.codeInput ?? .code,
            primaryButton: customStyle?.primaryButton ?? .primary
        )
        return NativeAlternativePaymentMethodStartedView(style: style)
    }()

    private lazy var submittedView: NativeAlternativePaymentMethodSubmittedView = {
        let style = NativeAlternativePaymentMethodSubmittedViewStyle(
            message: customStyle?.message ?? .init(color: Asset.Colors.Text.primary.color, typography: .headline),
            successMessage: customStyle?.successMessage ?? .init(
                color: Asset.Colors.Text.success.color, typography: .headline
            )
        )
        return NativeAlternativePaymentMethodSubmittedView(style: style)
    }()

    private var notificationObservers: [NSObjectProtocol]
    private var currentState: NativeAlternativePaymentMethodViewModelState?

    // MARK: - State Management

    private func configureWithViewModelState(animated: Bool) {
        let state = viewModel.state
        switch state {
        case .idle:
            configureWithIdleState()
        case .loading:
            configureWithLoadingState(animated: animated)
        case .started(let startedState):
            configure(with: startedState, animated: animated)
        case .submitted(let submittedState):
            configure(with: submittedState, animated: animated)
        }
        currentState = state
    }

    private func configureWithIdleState() {
        backgroundDecorationView.alpha = 0
        activityIndicatorView.alpha = 0
        startedView.alpha = 0
        submittedView.alpha = 0
    }

    private func configureWithLoadingState(animated: Bool) {
        backgroundDecorationView.configure(
            isExpanded: false, isSuccess: false, animated: backgroundDecorationView.alpha > 0.01 && animated
        )
        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            CATransaction.begin()
            CATransaction.setDisableActions(!animated)
            backgroundDecorationView.alpha = 1
            activityIndicatorView.alpha = 1
            startedView.alpha = 0
            submittedView.alpha = 0
            CATransaction.commit()
        }
    }

    private func configure(with startedState: NativeAlternativePaymentMethodViewModelState.Started, animated: Bool) {
        startedView.configure(with: startedState, animated: startedView.alpha > 0.01 && animated)
        backgroundDecorationView.configure(
            isExpanded: true, isSuccess: false, animated: backgroundDecorationView.alpha > 0.01 && animated
        )
        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            CATransaction.begin()
            CATransaction.setDisableActions(!animated)
            backgroundDecorationView.alpha = 0
            activityIndicatorView.alpha = 0
            startedView.alpha = 1
            submittedView.alpha = 0
            CATransaction.commit()
        }
    }

    private func configure(
        with submittedState: NativeAlternativePaymentMethodViewModelState.Submitted, animated: Bool
    ) {
        submittedView.configure(with: submittedState, animated: submittedView.alpha > 0.01 && animated)
        backgroundDecorationView.configure(
            isExpanded: false, isSuccess: true, animated: backgroundDecorationView.alpha > 0.01 && animated
        )
        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            CATransaction.begin()
            CATransaction.setDisableActions(!animated)
            backgroundDecorationView.alpha = 1
            activityIndicatorView.alpha = 0
            startedView.alpha = 0
            submittedView.alpha = 1
            CATransaction.commit()
        }
    }

    // MARK: - Notifications

    private func observeNotifications() {
        let willChangeFrameObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: nil,
            using: { [weak self] notification in
                self?.keyboardWillChangeFrame(notification: notification)
            }
        )
        let didChangeContentSizeCategoryObserver = NotificationCenter.default.addObserver(
            forName: UIContentSizeCategory.didChangeNotification,
            object: nil,
            queue: nil,
            using: { [weak self] _ in
                self?.configureWithViewModelState(animated: false)
            }
        )
        notificationObservers = [willChangeFrameObserver, didChangeContentSizeCategoryObserver]
    }

    // MARK: - Keyboard Handling

    private func keyboardWillChangeFrame(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let coveredSafeAreaHeight = view.bounds.height
            - view.convert(keyboardFrame, from: nil).minY
            - view.safeAreaInsets.bottom
            + additionalSafeAreaInsets.bottom
        additionalSafeAreaInsets.bottom = max(coveredSafeAreaHeight, 0)
        view.layoutIfNeeded()
    }
}
