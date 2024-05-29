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
public final class POWebAuthenticationSession {

    /// A completion handler for the web authentication session.
    public typealias Completion = (Result<URL, POFailure>) -> Void

    /// Starts the `POWebAuthenticationController` instance after it is instantiated.
    ///
    /// Start can only be called once for an `POWebAuthenticationController` instance. This also means calling start on a
    /// canceled session will fail.
    public func start() async -> Bool {
        guard state == nil else {
            preconditionFailure("Controller start must be attempted only once.")
        }
        guard let presentingViewController = PresentingViewControllerProvider.find() else {
            return false
        }
        let viewController = createViewController()
        associate(controller: self, with: viewController)
        state = .started(viewController: viewController)
        await withCheckedContinuation { continuation in
            presentingViewController.present(viewController, animated: true, completion: continuation.resume)
        }
        return true
    }

    /// Cancel an `POWebAuthenticationController`. If the view controller is already presented to load the webpage for
    /// authentication, it will be dismissed. Calling cancel on an already canceled session will have no effect.
    public func cancel() async {
        guard case .started(let viewController) = state else {
            return
        }
        // Break retain cycle to allow de-initialization of self.
        associate(controller: nil, with: viewController)
        await withCheckedContinuation { continuation in
            viewController.dismiss(animated: true, completion: continuation.resume)
        }
        state = .completed
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
        static var controller: UInt8 = 0
    }

    private enum State {
        case started(viewController: SFSafariViewController), completed
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

    private func complete(with result: Result<URL, POFailure>) {
        Task {
            await self.cancel()
        }
        completion(result)
    }

    private func associate(controller: POWebAuthenticationSession?, with object: Any) {
        objc_setAssociatedObject(object, &AssociatedKeys.controller, controller, .OBJC_ASSOCIATION_RETAIN)
    }
}
