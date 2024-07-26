//
//  POWebAuthenticationSession.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.05.2024.
//

import SafariServices
import AuthenticationServices
@_spi(PO) import ProcessOut

/// A session that an app uses to authenticate a payment.
@MainActor
public final class POWebAuthenticationSession: Sendable {

    /// A completion handler for the web authentication session.
    typealias Completion = @Sendable (Result<URL, POFailure>) -> Void

    /// Only call this method once for a given POWebAuthenticationSession instance after initialization.
    /// Calling the start() method on a canceled session results in a failure.
    ///
    /// After you call start(), the session instance stores a strong reference to itself. To avoid deallocation during
    /// the authentication process, the session keeps the reference until after it calls the completion handler.
    public func start() async -> Bool {
        guard state == nil else {
            preconditionFailure("Session start must be attempted only once.")
        }
        guard let presentingViewController = PresentingViewControllerProvider.find() else {
            return false
        }
        let viewController = createViewController()
        state = .started(viewController: viewController)
        await withCheckedContinuation { continuation in
            presentingViewController.present(viewController, animated: true, completion: continuation.resume)
        }
        associate(controller: self, with: viewController)
        return true
    }

    /// Cancels a web authentication session.
    ///
    /// If the session has already presented a view with the authentication webpage, calling this method dismisses
    /// that view. Calling cancel() on an already canceled/completed session has no effect.
    public func cancel() async {
        guard case .started(let viewController) = state else {
            return
        }
        // Break retain cycle to allow de-initialization of self.
        await withCheckedContinuation { continuation in
            viewController.dismiss(animated: true, completion: continuation.resume)
        }
        state = .cancelling
        associate(controller: nil, with: viewController)
    }

    // MARK: -

    init(
        url: URL,
        callback: POWebAuthenticationSessionCallback,
        timeout: TimeInterval? = nil,
        completion: @escaping Completion
    ) {
        self.url = url
        self.callback = callback
        self.timeout = timeout
        self.completion = completion
    }

    // MARK: - Private Nested Types

    private enum AssociatedKeys {
        nonisolated(unsafe) static var controller: UInt8 = 0
    }

    private enum State {
        case started(viewController: SFSafariViewController), cancelling, completed
    }

    // MARK: - Private Properties

    private let url: URL
    private let callback: POWebAuthenticationSessionCallback
    private let timeout: TimeInterval?
    private let completion: Completion
    private var state: State?

    // MARK: - Utils

    private func createViewController() -> SFSafariViewController {
        let viewController = SFSafariViewController(url: url)
        viewController.dismissButtonStyle = .cancel
        let viewModel = DefaultSafariViewModel(
            callback: callback,
            timeout: timeout,
            eventEmitter: ProcessOut.shared.eventEmitter,
            logger: ProcessOut.shared.logger,
            completion: { [weak self] result in
                self?.complete(with: result)
            }
        )
        viewController.setViewModel(viewModel)
        viewModel.start()
        return viewController
    }

    private nonisolated func complete(with result: Result<URL, POFailure>) {
        Task { @MainActor in
            await self.cancel()
            state = .completed
            completion(result)
        }
    }

    private func associate(controller: POWebAuthenticationSession?, with object: Any) {
        objc_setAssociatedObject(object, &AssociatedKeys.controller, controller, .OBJC_ASSOCIATION_RETAIN)
    }
}
