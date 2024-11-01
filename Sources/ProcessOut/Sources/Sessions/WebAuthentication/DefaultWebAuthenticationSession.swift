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
        let sessionProxy = WebAuthenticationSessionProxy()
        return try await withTaskCancellationHandler(
            operation: {
                try await withCheckedThrowingContinuation { continuation in
                    guard !Task.isCancelled else {
                        let failure = POFailure(message: "Authentication session was cancelled.", code: .cancelled)
                        continuation.resume(throwing: failure)
                        return
                    }
                    let session = Self.createAuthenticationSession(with: request) { result in
                        sessionProxy.invalidate()
                        continuation.resume(with: result)
                    }
                    session.prefersEphemeralWebBrowserSession = true
                    session.presentationContextProvider = self
                    sessionProxy.setSession(session, continuation: continuation)
                    if !session.start() {
                        // swiftlint:disable:next line_length
                        let failure = POFailure(message: "Unable to start authentication session.", code: .generic(.mobile))
                        continuation.resume(throwing: failure)
                    }
                }
            },
            onCancel: {
                sessionProxy.cancel()
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
private final class WebAuthenticationSessionProxy: Sendable {

    func setSession(_ session: ASWebAuthenticationSession, continuation: CheckedContinuation<URL, Error>) {
        self.session = session
        self.continuation = continuation
    }

    func invalidate() {
        session = nil
        continuation = nil
    }

    nonisolated func cancel() {
        Task { @MainActor in
            _cancel()
        }
    }

    // MARK: - Private Properties

    private var session: ASWebAuthenticationSession?
    private var continuation: CheckedContinuation<URL, Error>?

    // MARK: - Private Methods

    private func _cancel() {
        let failure = POFailure(message: "Authentication session was cancelled.", code: .cancelled)
        session?.cancel()
        continuation?.resume(throwing: failure)
        invalidate()
    }
}
