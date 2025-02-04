//
//  DefaultWebAuthenticationSession.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.08.2024.
//

import AuthenticationServices

@MainActor
final class DefaultWebAuthenticationSession:
    NSObject, WebAuthenticationSession, ASWebAuthenticationPresentationContextProviding {

    nonisolated init(eventEmitter: POEventEmitter) {
        self.eventEmitter = eventEmitter
        super.init()
    }

    // MARK: - WebAuthenticationSession

    func authenticate(using request: WebAuthenticationRequest) async throws -> URL {
        let operationProxy = WebAuthenticationOperationProxy(eventEmitter: eventEmitter)
        return try await withTaskCancellationHandler(
            operation: {
                try await withCheckedThrowingContinuation { continuation in
                    let session = Self.createAuthenticationSession(with: request) { result in
                        operationProxy.setCompleted(with: result)
                    }
                    session.prefersEphemeralWebBrowserSession = request.prefersEphemeralSession
                    session.presentationContextProvider = self
                    operationProxy.set(session: session, continuation: continuation)
                    if Task.isCancelled {
                        let failure = POFailure(message: "Authentication was cancelled.", code: .cancelled)
                        operationProxy.setCompleted(with: .failure(failure))
                    } else if !session.start() {
                        let failure = POFailure(message: "Unable to start authentication.", code: .generic(.mobile))
                        operationProxy.setCompleted(with: .failure(failure))
                    }
                }
            },
            onCancel: {
                Task { @MainActor in operationProxy.cancel() }
            }
        )
    }

    // MARK: - ASWebAuthenticationPresentationContextProviding

    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            let application = UIApplication.shared
            for scene in application.connectedScenes {
                // The scene of returned presentation anchor is expected to be in
                // foreground active state otherwise authentication start fails.
                if scene.activationState != .foregroundActive {
                    continue
                }
                let windowScene = scene as? UIWindowScene
                guard let window = windowScene?.windows.first(where: \.isKeyWindow) else {
                    continue
                }
                return window
            }
            return ASPresentationAnchor()
        }
    }

    // MARK: - Private Properties

    private let eventEmitter: POEventEmitter

    // MARK: - Private Methods

    private static func createAuthenticationSession(
        with request: WebAuthenticationRequest, completion: @escaping (Result<URL, POFailure>) -> Void
    ) -> ASWebAuthenticationSession {
        let completionHandler = { (url: URL?, error: Error?) in
            if let url {
                completion(.success(url))
            } else if let error {
                completion(.failure(Self.converted(error: error)))
            } else {
                preconditionFailure("Unexpected ASWebAuthenticationSession completion result.")
            }
        }
        switch request.callback?.value {
        case .scheme(let scheme):
            return ASWebAuthenticationSession(
                url: request.url, callbackURLScheme: scheme, completionHandler: completionHandler
            )
        case let .https(host, path):
            if #available(iOS 17.4, *) {
                return ASWebAuthenticationSession(
                    url: request.url, callback: .https(host: host, path: path), completionHandler: completionHandler
                )
            } else {
                preconditionFailure("HTTPs callback is unavailable before iOS 17.4")
            }
        case nil:
            return ASWebAuthenticationSession(
                url: request.url, callbackURLScheme: nil, completionHandler: completionHandler
            )
        }
    }

    private static func converted(error: Error) -> POFailure {
        guard let error = error as? ASWebAuthenticationSessionError else {
            return POFailure(code: .generic(.mobile), underlyingError: error)
        }
        let poCode: POFailure.Code
        switch error.code {
        case .canceledLogin:
            poCode = .cancelled
        case .presentationContextNotProvided, .presentationContextInvalid:
            poCode = .internal(.mobile)
        @unknown default:
            poCode = .generic(.mobile)
        }
        return POFailure(code: poCode, underlyingError: error)
    }
}

@MainActor
private final class WebAuthenticationOperationProxy {

    init(eventEmitter: POEventEmitter) {
        self.eventEmitter = eventEmitter
    }

    func set(session: ASWebAuthenticationSession, continuation: CheckedContinuation<URL, Error>) {
        switch state {
        case nil:
            let newState = State.Processing(
                continuation: continuation,
                session: session,
                startTime: .now()
            )
            state = .processing(newState)
            observeEvents()
        case .processing:
            assertionFailure("Already in processing state.")
        case .completed(let result):
            continuation.resume(with: result)
        }
    }

    func setCompleted(with newResult: Result<URL, POFailure>) {
        switch state {
        case nil:
            state = .completed(newResult)
        case .processing(let currentState):
            currentState.continuation.resume(with: newResult)
            state = .completed(newResult)
        case .completed:
            break // Already completed
        }
        deepLinkObservation = nil
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

            /// Start tme.
            let startTime: DispatchTime
        }

        case processing(Processing), completed(Result<URL, POFailure>)
    }

    // MARK: - Private Properties

    private let eventEmitter: POEventEmitter
    private var state: State?, deepLinkObservation: AnyObject?

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

    private func observeEvents() {
        // todo(andrii-vysotskyi): match url content
        deepLinkObservation = eventEmitter.on(PODeepLinkReceivedEvent.self) { [weak self] event in
            Task { @MainActor in
                self?.setCompleted(with: .success(event.url))
            }
            return true
        }
    }
}
