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
        let view = UIView()
        view.backgroundColor = Asset.Colors.Background.primary.color
        view.addSubview(startedView)
        view.addSubview(backgroundDecorationView)
        view.addSubview(activityIndicatorView)
        view.addSubview(successView)
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
            successView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            successView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            successView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ]
        self.view = view
        NSLayoutConstraint.activate(constraints)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        observeKeyboardNotifications()
        viewModel.start()
        viewModel.didChange = { [weak self] in self?.configureWithViewModelState() }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let animationDuration: TimeInterval = 0.35
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
        view.setAnimating(true)
        return view
    }()

    private lazy var backgroundDecorationView: BackgroundDecorationView = {
        let view = BackgroundDecorationView(style: customStyle?.backgroundDecoration ?? .default)
        view.alpha = 0
        return view
    }()

    private lazy var startedView: NativeAlternativePaymentMethodStartedView = {
        let style = NativeAlternativePaymentMethodStartedViewStyle(
            title: customStyle?.title ?? .init(color: Asset.Colors.Text.primary.color, typography: .title),
            input: customStyle?.input ?? .default,
            codeInput: customStyle?.codeInput ?? .code,
            primaryButton: customStyle?.primaryButton ?? .primary
        )
        let view = NativeAlternativePaymentMethodStartedView(style: style)
        view.alpha = 0
        return view
    }()

    private lazy var successView: NativeAlternativePaymentMethodSuccessView = {
        let style = NativeAlternativePaymentMethodSuccessViewStyle(
            message: customStyle?.successMessage ?? .init(color: Asset.Colors.Text.success.color, typography: .headline)
        )
        let view = NativeAlternativePaymentMethodSuccessView(style: style)
        view.alpha = 0
        return view
    }()

    private var notificationObservers: [NSObjectProtocol]
    private var previousState: NativeAlternativePaymentMethodViewModelState?

    // MARK: - State Management

    private func configureWithViewModelState() {
        switch viewModel.state {
        case .idle:
            break
        case .loading:
            configureWithLoadingState()
        case .started(let startedState):
            configure(with: startedState)
        case .success(let successState):
            configure(with: successState)
        default:
            break
        }
        previousState = viewModel.state
    }

    private func configureWithLoadingState() {
        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            backgroundDecorationView.configure(
                isExpanded: false, isSuccess: false, animated: backgroundDecorationView.isVisible
            )
            backgroundDecorationView.alpha = 1
            activityIndicatorView.alpha = 1
            startedView.alpha = 0
            successView.alpha = 0
        }
    }

    private func configure(with startedState: NativeAlternativePaymentMethodViewModelState.Started) {
        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            backgroundDecorationView.configure(
                isExpanded: true, isSuccess: false, animated: backgroundDecorationView.isVisible
            )
            backgroundDecorationView.alpha = 0
            activityIndicatorView.alpha = 0
            startedView.configure(with: startedState, animated: startedView.isVisible)
            startedView.alpha = 1
            successView.alpha = 0
        }
    }

    private func configure(with successState: NativeAlternativePaymentMethodViewModelState.Success) {
        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            backgroundDecorationView.configure(
                isExpanded: false, isSuccess: true, animated: backgroundDecorationView.isVisible
            )
            backgroundDecorationView.alpha = 1
            activityIndicatorView.alpha = 0
            startedView.alpha = 0
            successView.configure(with: successState, animated: successView.isVisible)
            successView.alpha = 1
        }
    }

    // MARK: - Keyboard Handling

    private func observeKeyboardNotifications() {
        let willChangeFrameObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: nil,
            using: { [weak self] notification in
                self?.keyboardWillChangeFrame(notification: notification)
            }
        )
        notificationObservers = [willChangeFrameObserver]
    }

    private func keyboardWillChangeFrame(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let coveredSafeAreaHeight = view.bounds.height
            - view.convert(keyboardFrame, from: nil).minY
            - view.safeAreaInsets.bottom
            + additionalSafeAreaInsets.bottom
        additionalSafeAreaInsets.bottom = max(coveredSafeAreaHeight, 0)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

private extension UIView { // swiftlint:disable:this no_extension_access_modifier

    var isVisible: Bool {
        window != nil && !isHidden && alpha > 0.01
    }
}
