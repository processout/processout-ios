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
        let operationProxy = WebAuthenticationOperationProxy(
            callback: request.callback, eventEmitter: eventEmitter
        )
        return try await withTaskCancellationHandler(
            operation: {
                let redirectUrl = try Self.normalize(url: request.url)
                return try await withCheckedThrowingContinuation { continuation in
                    let session = Self.createAuthenticationSession(with: request, redirectUrl: redirectUrl) { result in
                        operationProxy.setCompleted(with: result)
                    }
                    session.prefersEphemeralWebBrowserSession = request.prefersEphemeralSession
                    session.presentationContextProvider = self
                    operationProxy.set(session: session, continuation: continuation)
                    if Task.isCancelled {
                        let failure = POFailure(message: "Authentication was cancelled.", code: .Mobile.cancelled)
                        operationProxy.setCompleted(with: .failure(failure))
                    } else if !session.start() {
                        let failure = POFailure(message: "Unable to start authentication.", code: .Mobile.generic)
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
        with request: WebAuthenticationRequest, redirectUrl: URL, completion: @escaping (Result<URL, POFailure>) -> Void
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
                url: redirectUrl, callbackURLScheme: scheme, completionHandler: completionHandler
            )
        case let .https(host, path):
            if #available(iOS 17.4, *) {
                return ASWebAuthenticationSession(
                    url: redirectUrl, callback: .https(host: host, path: path), completionHandler: completionHandler
                )
            } else {
                preconditionFailure("HTTPs callback is unavailable before iOS 17.4")
            }
        case nil:
            return ASWebAuthenticationSession(
                url: redirectUrl, callbackURLScheme: nil, completionHandler: completionHandler
            )
        }
    }

    private static func normalize(url: URL) throws(POFailure) -> URL {
        let supportedSchemes: Set<String> = ["http", "https"]
        if let scheme = url.scheme, supportedSchemes.contains(scheme) {
            return url
        }
        guard url.scheme == nil, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw POFailure(message: "Redirect URL is not supported.", code: .Mobile.generic)
        }
        let defaultScheme = "https"
        urlComponents.scheme = urlComponents.host ?? defaultScheme
        return urlComponents.url ?? url
    }

    private static func converted(error: Error) -> POFailure {
        guard let error = error as? ASWebAuthenticationSessionError else {
            return POFailure(code: .Mobile.generic, underlyingError: error)
        }
        let poCode: POFailureCode
        switch error.code {
        case .canceledLogin:
            poCode = .Mobile.cancelled
        case .presentationContextNotProvided, .presentationContextInvalid:
            poCode = .Mobile.internal
        @unknown default:
            poCode = .Mobile.generic
        }
        return POFailure(code: poCode, underlyingError: error)
    }
}
