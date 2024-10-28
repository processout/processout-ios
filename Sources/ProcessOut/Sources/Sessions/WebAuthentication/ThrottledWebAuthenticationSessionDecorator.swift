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
        semaphore = POAsyncSemaphore(value: 1)
    }

    // MARK: - WebAuthenticationSession

    func authenticate(
        using url: URL, callbackScheme: String?, additionalHeaderFields: [String: String]?
    ) async throws -> URL {
        do {
            try await semaphore.waitUnlessCancelled()
        } catch {
            throw POFailure(message: "Authentication session was cancelled.", code: .cancelled)
        }
        defer {
            lastAuthenticationTime = DispatchTime.now()
            semaphore.signal()
        }
        await delayAuthenticationIfNeeded()
        return try await self.session.authenticate(
            using: url, callbackScheme: callbackScheme, additionalHeaderFields: additionalHeaderFields
        )
    }

    // MARK: - Private Properties

    private let session: WebAuthenticationSession
    private let semaphore: POAsyncSemaphore

    private var lastAuthenticationTime: DispatchTime?

    // MARK: - Private Methods

    /// `ASWebAuthenticationSession`'s `completionHandler` is invoked before session is
    /// dismissed. In attempt to workaround presentation issues sequential authentications are delayed.
    /// See https://github.com/aws-amplify/amplify-swift/issues/959 for similar issue.
    private func delayAuthenticationIfNeeded() async {
        guard let lastAuthenticationTime else {
            return
        }
        let elapsedTime = DispatchTime.now().uptimeNanoseconds - lastAuthenticationTime.uptimeNanoseconds
        let expectedDelay = 1 * NSEC_PER_SEC
        let delay = expectedDelay.subtractingReportingOverflow(elapsedTime)
        guard !delay.overflow else {
            return
        }
        try? await Task.sleep(nanoseconds: delay.partialValue)
    }
}
