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
            startedView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
        static let backgroundDecorationLoadingHeight: CGFloat = 476
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
        default:
            break
        }
        previousState = viewModel.state
    }

    private func configureWithLoadingState() {
        if backgroundDecorationView.alpha < 0.01 {
            UIView.performWithoutAnimation {
                let height = Constants.backgroundDecorationLoadingHeight
                backgroundDecorationView.configure(coveredHeight: height, isSuccess: false, animated: false)
                backgroundDecorationView.layoutIfNeeded()
            }
        } else {
            let height = Constants.backgroundDecorationLoadingHeight
            backgroundDecorationView.configure(coveredHeight: height, isSuccess: false, animated: true)
        }
        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            activityIndicatorView.alpha = 1
            backgroundDecorationView.alpha = 1
            startedView.alpha = 0
        }
    }

    private func configure(with startedState: NativeAlternativePaymentMethodViewModelState.Started) {
        if startedView.alpha < 0.01 {
            UIView.performWithoutAnimation {
                startedView.configure(with: startedState, animated: false)
                startedView.layoutIfNeeded()
            }
        } else {
            startedView.configure(with: startedState, animated: true)
        }
        UIView.animate(withDuration: Constants.animationDuration) { [self] in
            activityIndicatorView.alpha = 0
            backgroundDecorationView.configure(coveredHeight: nil, isSuccess: false, animated: true)
            backgroundDecorationView.alpha = 0
            startedView.alpha = 1
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
