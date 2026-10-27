//
//  ThrottledWebAuthenticationSessionDecorator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 09.10.2024.
//

import Foundation

actor ThrottledWebAuthenticationSessionDecorator: POWebAuthenticationSession {

    init(session: POWebAuthenticationSession) {
        self.session = session
    }

    // MARK: - WebAuthenticationSession

    func authenticate(using request: POWebAuthenticationRequest) async throws -> URL {
        let previousAuthentication = lastAuthentication
        let authentication = Task<URL, Error> {
            // Wait for the predecessor regardless of its outcome. The wait itself is not
            // cancellable, so cancellation requested while queued is observed only after
            // the predecessor completes.
            _ = await previousAuthentication?.result
            if Task.isCancelled {
                throw POFailure(message: "Authentication session was cancelled.", code: .Mobile.cancelled)
            }
            await delayAuthenticationIfNeeded()
            defer {
                lastAuthenticationTime = DispatchTime.now()
            }
            return try await session.authenticate(using: request)
        }
        lastAuthentication = authentication
        return try await withTaskCancellationHandler(
            operation: {
                try await authentication.value
            },
            onCancel: authentication.cancel
        )
    }

    // MARK: - Private Properties

    private let session: POWebAuthenticationSession
    private var lastAuthentication: Task<URL, Error>?

    // MARK: - Authentication Delay

    private var lastAuthenticationTime: DispatchTime?

    /// `ASWebAuthenticationSession`'s `completionHandler` is invoked before session is
    /// dismissed. In attempt to workaround presentation issues sequential authentications are delayed.
    /// See https://github.com/aws-amplify/amplify-swift/issues/959 for similar issue.
    private func delayAuthenticationIfNeeded() async {
        guard let lastAuthenticationTime else {
            return
        }
        let minimumDelay: TimeInterval = 1
        let delay = minimumDelay - (DispatchTime.now().uptimeSeconds - lastAuthenticationTime.uptimeSeconds)
        guard delay > 0 else {
            return
        }
        try? await Task.sleep(seconds: delay)
    }
}
