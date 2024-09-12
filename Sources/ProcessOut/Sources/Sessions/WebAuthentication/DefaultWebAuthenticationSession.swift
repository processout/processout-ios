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

    func authenticate(
        using url: URL, callbackScheme: String?, additionalHeaderFields: [String: String]?
    ) async throws -> URL {
        let sessionProxy = WebAuthenticationSessionProxy()
        return try await withTaskCancellationHandler(
            operation: {
                try await withCheckedThrowingContinuation { continuation in
                    guard !Task.isCancelled else {
                        let failure = POFailure(message: "Authentication session was cancelled.", code: .cancelled)
                        continuation.resume(throwing: failure)
                        return
                    }
                    let session = ASWebAuthenticationSession(
                        url: url,
                        callbackURLScheme: callbackScheme,
                        completionHandler: { url, error in
                            sessionProxy.invalidate()
                            if let error {
                                continuation.resume(throwing: Self.converted(error: error))
                            } else if let url {
                                continuation.resume(returning: url)
                            } else {
                                preconditionFailure("Unexpected ASWebAuthenticationSession completion result.")
                            }
                        }
                    )
                    session.prefersEphemeralWebBrowserSession = true
                    session.presentationContextProvider = self
                    if #available(iOS 17.4, *) {
                        session.additionalHeaderFields = additionalHeaderFields
                    }
                    sessionProxy.setSession(session, continuation: continuation)
                    session.start()
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
