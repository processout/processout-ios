//
//  WebAuthenticationOperationProxy.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.02.2025.
//

import AuthenticationServices

@MainActor
final class WebAuthenticationOperationProxy {

    init(callback: POWebAuthenticationCallback?, eventEmitter: POEventEmitter) {
        self.callback = callback
        self.eventEmitter = eventEmitter
    }

    func set(session: ASWebAuthenticationSession, continuation: CheckedContinuation<URL, POFailure>) {
        switch state {
        case nil:
            let observation = eventEmitter.on(PODeepLinkReceivedEvent.self) { [weak self] event in
                self?.setCompleted(with: event) ?? false
            }
            let newState = State.Processing(
                continuation: continuation,
                session: session,
                observation: observation,
                startTime: .now()
            )
            state = .processing(newState)
        case .processing:
            assertionFailure("Already in processing state.")
        case .completed(let result):
            continuation.resume(with: result)
            cancel(session: session)
        }
    }

    func setCompleted(with newResult: Result<URL, POFailure>) {
        switch state {
        case nil:
            state = .completed(newResult)
        case .processing(let currentState):
            state = .completed(newResult)
            currentState.continuation.resume(with: newResult)
            cancel(session: currentState.session, startTime: currentState.startTime)
        case .completed:
            break // Already completed
        }
    }

    func cancel() {
        if case .processing(let currentState) = state {
            cancel(session: currentState.session, startTime: currentState.startTime)
        }
        let failure = POFailure(message: "Authentication was cancelled.", code: .Mobile.cancelled)
        setCompleted(with: .failure(failure))
    }

    // MARK: - Private Nested Types

    @MainActor
    private enum State {

        @MainActor
        struct Processing { // swiftlint:disable:this nesting

            /// Continuation.
            let continuation: CheckedContinuation<URL, POFailure>

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

    private nonisolated let callback: POWebAuthenticationCallback?, eventEmitter: POEventEmitter
    private var state: State?

    // MARK: - Private Methods

    /// Cancels given session.
    ///
    /// Calling `cancel` before session is actually presented seems to have no effect. This method uses
    /// a workaround that adds a delay to ensure cancel is called at least 0.3 seconds after the session start.
    private func cancel(session: ASWebAuthenticationSession, startTime: DispatchTime = DispatchTime.now()) {
        let minimumDelay: TimeInterval = 0.3
        Task { @MainActor in
            let delay = minimumDelay - (DispatchTime.now().uptimeSeconds - startTime.uptimeSeconds)
            if delay > 0 {
                try? await Task.sleep(seconds: delay)
            }
            session.cancel()
        }
    }

    private nonisolated func setCompleted(with event: PODeepLinkReceivedEvent) -> Bool {
        if let callback, !callback.matches(url: event.url) {
            return false
        }
        Task { @MainActor in
            setCompleted(with: .success(event.url))
        }
        return true
    }
}
