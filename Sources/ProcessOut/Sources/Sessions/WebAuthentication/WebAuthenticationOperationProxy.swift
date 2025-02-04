//
//  WebAuthenticationOperationProxy.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.02.2025.
//

import AuthenticationServices

@MainActor
final class WebAuthenticationOperationProxy {

    init(eventEmitter: POEventEmitter) {
        self.eventEmitter = eventEmitter
    }

    func set(session: ASWebAuthenticationSession, continuation: CheckedContinuation<URL, Error>) {
        switch state {
        case nil:
            let observation = eventEmitter.on(PODeepLinkReceivedEvent.self) { [weak self] event in
                // todo(andrii-vysotskyi): validate URL against request.callback
                Task { @MainActor in
                    self?.setCompleted(with: .success(event.url))
                }
                return true
            }
            let newState = State.Processing(
                continuation: continuation, session: session, observation: observation, startTime: .now()
            )
            state = .processing(newState)
        case .processing:
            assertionFailure("Already in processing state.")
        case .completed(let result):
            continuation.resume(with: result)
            session.cancel()
        }
    }

    func setCompleted(with newResult: Result<URL, POFailure>) {
        switch state {
        case nil:
            state = .completed(newResult)
        case .processing(let currentState):
            state = .completed(newResult)
            currentState.continuation.resume(with: newResult)
            currentState.session.cancel()
        case .completed:
            break // Already completed
        }
    }

    func cancel() {
        cancelAuthenticationSessionIfNeeded()
        let failure = POFailure(message: "Authentication was cancelled.", code: .cancelled)
        setCompleted(with: .failure(failure))
    }

    // MARK: - Private Nested Types

    @MainActor
    private enum State {

        @MainActor
        struct Processing { // swiftlint:disable:this nesting

            /// Continuation.
            let continuation: CheckedContinuation<URL, Error>

            /// Authentication session.
            let session: ASWebAuthenticationSession

            /// OOB deep link observation.
            let observation: AnyObject

            /// Start tme.
            let startTime: DispatchTime
        }

        case processing(Processing), completed(Result<URL, POFailure>)
    }

    // MARK: - Private Properties

    private let eventEmitter: POEventEmitter
    private var state: State?

    // MARK: - Private Methods

    /// Cancels the current ASWebAuthenticationSession if needed.
    private func cancelAuthenticationSessionIfNeeded() {
        guard case .processing(let currentState) = state else {
            return
        }
        // Calling `cancel` before session is actually presented seems to have no effect. This workaround adds
        // a delay to ensure cancel is called at least 0.3 seconds after the session start.
        let minimumDelay: TimeInterval = 0.3
        let delay = minimumDelay - (DispatchTime.now().uptimeSeconds - currentState.startTime.uptimeSeconds)
        if delay > 0 {
            Task { @MainActor in
                try? await Task.sleep(seconds: delay)
                currentState.session.cancel()
            }
        } else {
            currentState.session.cancel()
        }
    }
}
