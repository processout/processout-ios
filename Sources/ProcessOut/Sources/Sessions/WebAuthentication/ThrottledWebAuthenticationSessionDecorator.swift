//
//  ThrottledWebAuthenticationSessionDecorator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 09.10.2024.
//

import Foundation

actor ThrottledWebAuthenticationSessionDecorator: WebAuthenticationSession {

    init(session: WebAuthenticationSession) {
        self.session = session
        semaphore = AsyncSemaphore(value: 1)
    }

    // MARK: - WebAuthenticationSession

    func authenticate(using request: WebAuthenticationRequest) async throws -> URL {
        try await semaphore.waitUnlessCancelled(
            cancellationError: POFailure(message: "Authentication session was cancelled.", code: .Mobile.cancelled)
        )
        defer {
            lastAuthenticationTime = DispatchTime.now()
            semaphore.signal()
        }
        await delayAuthenticationIfNeeded()
        return try await self.session.authenticate(using: request)
    }

    // MARK: - Private Properties

    private let session: WebAuthenticationSession
    private let semaphore: AsyncSemaphore

    private var lastAuthenticationTime: DispatchTime?

    // MARK: - Private Methods

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
