//
//  DefaultSafariViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import Foundation
import SafariServices
@_spi(PO) import ProcessOut

final class DefaultSafariViewModel: NSObject, SFSafariViewControllerDelegate {

    init(
        configuration: DefaultSafariViewModelConfiguration,
        eventEmitter: POEventEmitter,
        logger: POLogger,
        completion: @escaping (Result<URL, POFailure>) -> Void
    ) {
        self.configuration = configuration
        self.eventEmitter = eventEmitter
        self.logger = logger
        self.completion = completion
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
        deepLinkObserver = eventEmitter.on(PODeepLinkReceivedEvent.self) { [weak self] event in
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
    private let eventEmitter: POEventEmitter
    private let logger: POLogger
    private let completion: (Result<URL, POFailure>) -> Void

    private var state: State
    private var deepLinkObserver: AnyObject?
    private var timeoutTimer: Timer?

    // MARK: - Private Methods

    private func setCompletedState(with url: URL) -> Bool {
        if case .completed = state {
            logger.error("Can't change state to completed because already in sink state.")
            return false
        }
        guard matchesUrl(url) else {
            logger.debug("Ignoring unrelated url: \(url)")
            return false
        }
        invalidateObservers()
        state = .completed
        logger.info("Did complete with url: \(url)")
        completion(.success(url))
        return true
    }

    private func setCompletedState(with failure: POFailure) {
        if case .completed = state {
            logger.error("Can't change state to completed because already in a sink state.")
            return
        }
        invalidateObservers()
        state = .completed
        logger.debug("Did complete with error: \(failure)")
        completion(.failure(failure))
    }

    private func invalidateObservers() {
        timeoutTimer?.invalidate()
        deepLinkObserver = nil
    }

    // todo(andrii-vysotskyi): consider validating whether url is related to initial request if possible
    private func matchesUrl(_ url: URL) -> Bool {
        let returnUrl = configuration.returnUrl
        return url.scheme == returnUrl.scheme && url.host == returnUrl.host && url.path == returnUrl.path
    }
}
