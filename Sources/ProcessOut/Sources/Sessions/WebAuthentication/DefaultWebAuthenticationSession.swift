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

    override nonisolated init() {
        // Ignored
    }

    // MARK: - WebAuthenticationSession

    func authenticate(using request: WebAuthenticationRequest) async throws -> URL {
        let operationProxy = WebAuthenticationOperationProxy()
        return try await withTaskCancellationHandler(
            operation: {
                try await withCheckedThrowingContinuation { continuation in
                    if Task.isCancelled {
                        let failure = POFailure(message: "Authentication was cancelled.", code: .cancelled)
                        continuation.resume(throwing: failure)
                    } else {
                        let session = Self.createAuthenticationSession(with: request) { result in
                            operationProxy.setCompleted(with: result)
                        }
                        session.prefersEphemeralWebBrowserSession = true
                        session.presentationContextProvider = self
                        operationProxy.set(session: session, continuation: continuation)
                        guard !session.start() else {
                            return
                        }
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
            let scene = application.connectedScenes.first { $0 is UIWindowScene } as? UIWindowScene
            let window = scene?.windows.first(where: \.isKeyWindow)
            return window ?? ASPresentationAnchor()
        }
    }

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
private final class WebAuthenticationOperationProxy: Sendable {

    func set(session: ASWebAuthenticationSession, continuation: CheckedContinuation<URL, Error>) {
        switch state {
        case nil:
            state = .processing(continuation, session)
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
        case let .processing(continuation, _):
            continuation.resume(with: newResult)
            state = .completed(newResult)
        case .completed:
            break // Already completed
        }
    }

    func cancel() {
        if case .processing(_, let session) = state {
            session.cancel()
        }
        let failure = POFailure(message: "Authentication was cancelled.", code: .cancelled)
        setCompleted(with: .failure(failure))
    }

    // MARK: - Private Nested Types

    @MainActor
    private enum State: Sendable {
        case processing(CheckedContinuation<URL, Error>, ASWebAuthenticationSession), completed(Result<URL, POFailure>)
    }

    // MARK: - Private Properties

    private var state: State?
}
