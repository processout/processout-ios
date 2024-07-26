//
//  BaseViewController.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2023.
//

import UIKit

@available(*, deprecated)
class BaseViewController<Model>: UIViewController where Model: ViewModel {

    init(viewModel: Model, logger: POLogger) {
        self.viewModel = viewModel
        self.logger = logger
        keyboardHeight = 0
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.start()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeKeyboardChanges()
        viewModel.didChange = { [weak self] in self?.viewModelDidChange() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.didChange = nil
        removeKeyboardChangesObserver()
    }

    // MARK: -

    func configure(with state: Model.State, animated: Bool) {
        // Ignored
    }

    func keyboardWillChange(newHeight: CGFloat) {
        logger.debug("Keyboard height will change to \(newHeight)")
    }

    let viewModel: Model

    // MARK: - Private Properties

    private let logger: POLogger
    private var keyboardHeight: CGFloat

    // MARK: - Private Methods

    private func viewModelDidChange() {
        // There may be UI glitches if view is updated when being tracked by user. So
        // as a workaround, configuration is postponed to a point when tracking ends.
        guard RunLoop.current.currentMode != .tracking else {
            RunLoop.current.perform {
                MainActor.assumeIsolated(self.viewModelDidChange)
            }
            return
        }
        // View is configured without animation if it is not yet part of the hierarchy to avoid visual issues.
        configure(with: viewModel.state, animated: viewIfLoaded?.window != nil)
    }

    // MARK: - Keyboard Handling

    private func observeKeyboardChanges() {
        let notificationName = UIResponder.keyboardWillChangeFrameNotification
        let selector = #selector(keyboardWillChangeFrame(notification:))
        NotificationCenter.default.addObserver(self, selector: selector, name: notificationName, object: nil)
    }

    private func removeKeyboardChangesObserver() {
        let notificationName = UIResponder.keyboardWillChangeFrameNotification
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }

    @objc private func keyboardWillChangeFrame(notification: Notification) {
        guard let notification = KeyboardNotification(notification: notification) else {
            return
        }
        // Keyboard updates are not always animated so defaults are provided for smoother UI.
        let animator = UIViewPropertyAnimator(
            duration: notification.animationDuration ?? Constants.keyboardAnimationDuration,
            curve: notification.animationCurve ?? .easeInOut,
            animations: { [self] in
                let coveredSafeAreaHeight = view.bounds.height
                    - view.convert(notification.frameEnd, from: nil).minY
                    - view.safeAreaInsets.bottom
                let keyboardHeight = max(coveredSafeAreaHeight, 0)
                guard self.keyboardHeight != keyboardHeight else {
                    return
                }
                keyboardWillChange(newHeight: keyboardHeight)
                self.keyboardHeight = keyboardHeight
            }
        )
        // An implementation of `UICollectionView.performBatchUpdates` resigns first responder if item associated
        // with a cell containing it is invalidated, for example moved, deleted or reloaded. And since keyboard
        // notification is sent as part of resign operation, we shouldn't call `performBatchUpdates` directly here
        // to avoid recursion which causes weird artifacts and inconsistency. To break it, keyboard animation info
        // is extracted from notification and update is scheduled for next run loop iteration. Collection layout
        // update is needed here in a first place because layout depends on inset, which transitively depends on
        // keyboard visibility.
        RunLoop.current.perform {
            MainActor.assumeIsolated(animator.startAnimation)
        }
    }
}

private enum Constants {
    static let keyboardAnimationDuration: TimeInterval = 0.25
}
