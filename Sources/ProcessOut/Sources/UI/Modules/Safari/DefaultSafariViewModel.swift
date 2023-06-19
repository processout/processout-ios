//
//  DefaultSafariViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import Foundation
import SafariServices

final class DefaultSafariViewModel: NSObject, SFSafariViewControllerDelegate {

    init(
        configuration: DefaultSafariViewModelConfiguration,
        eventEmitter: EventEmitter,
        logger: POLogger,
        delegate: DefaultSafariViewModelDelegate
    ) {
        self.configuration = configuration
        self.eventEmitter = eventEmitter
        self.logger = logger
        self.delegate = delegate
        state = .idle
    }

    func start() {
        guard case .idle = state else {
            return
        }
        if let timeout = configuration.timeout {
            timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
                self?.setCompletedState(with: POFailure(code: .timeout(.mobile)))
            }
        }
        deepLinkObserver = eventEmitter.on(DeepLinkReceivedEvent.self) { [weak self] event in
            self?.setCompletedState(with: event.url) ?? false
        }
        state = .started
    }

    // MARK: - SFSafariViewControllerDelegate

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if state != .completed {
            logger.debug("Safari did finish, but state is not completed, handling as cancelation")
            let failure = POFailure(code: .cancelled)
            setCompletedState(with: failure)
        }
    }

    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if !didLoadSuccessfully {
            logger.debug("Safari failed to load initial url, aborting")
            let failure = POFailure(code: .generic(.mobile))
            setCompletedState(with: failure)
        }
    }

    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo url: URL) {
        logger.debug("Safari did redirect to url: \(url)")
    }

    // MARK: - Private Nested Types

    private enum State {

        /// View model is currently idle and waiting for start.
        case idle

        /// View model has been started and is currently operating.
        case started

        /// View model did complete with either success or failure.
        case completed
    }

    // MARK: - Private Properties

    private let configuration: DefaultSafariViewModelConfiguration
    private let eventEmitter: EventEmitter
    private let logger: POLogger
    private let delegate: DefaultSafariViewModelDelegate

    private var state: State
    private var deepLinkObserver: AnyObject?
    private var timeoutTimer: Timer?

    // MARK: - Private Methods

    private func setCompletedState(with url: URL) -> Bool {
        if case .completed = state {
            logger.error("Can't change state to completed because already in sink state.")
            return false
        }
        // todo(andrii-vysotskyi): consider validating whether url is related to initial request if possible
        guard url.scheme == configuration.returnUrl.scheme,
              url.host == configuration.returnUrl.host,
              url.path == configuration.returnUrl.path else {
            logger.debug("Ignoring unrelated url: \(url)")
            return false
        }
        do {
            try delegate.complete(with: url)
            invalidateObservers()
            state = .completed
            logger.info("Did complete with url: \(url)")
        } catch {
            setCompletedState(with: error)
        }
        return true
    }

    private func setCompletedState(with error: Error) {
        if case .completed = state {
            logger.error("Can't change state to completed because already in a sink state.")
            return
        }
        let failure: POFailure
        if let error = error as? POFailure {
            failure = error
        } else {
            failure = POFailure(message: nil, code: .generic(.mobile), underlyingError: error)
        }
        invalidateObservers()
        state = .completed
        logger.debug("Did complete with error: \(failure)")
        delegate.complete(with: failure)
    }

    private func invalidateObservers() {
        timeoutTimer?.invalidate()
        deepLinkObserver = nil
    }
}
