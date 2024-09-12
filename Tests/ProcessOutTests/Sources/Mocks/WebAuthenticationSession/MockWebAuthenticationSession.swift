//
//  MockWebAuthenticationSession.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.09.2024.
//

import Foundation
@testable @_spi(PO) import ProcessOut

final class MockWebAuthenticationSession: WebAuthenticationSession {

    var authenticateCallsCount: Int {
        lock.withLock { _authenticateCallsCount }
    }

    var authenticateFromClosure: ((URL, String?, [String: String]?) async throws -> URL)! {
        get { lock.withLock { _authenticateFromClosure } }
        set { lock.withLock { _authenticateFromClosure = newValue } }
    }

    // MARK: -

    func authenticate(
        using url: URL, callbackScheme: String?, additionalHeaderFields: [String: String]?
    ) async throws -> URL {
        let authenticate = lock.withLock {
            _authenticateCallsCount += 1
            return _authenticateFromClosure
        }
        return try await authenticate!(url, callbackScheme, additionalHeaderFields)
    }

    // MARK: - Private Properties

    private let lock = POUnfairlyLocked()

    private nonisolated(unsafe) var _authenticateCallsCount = 0
    private nonisolated(unsafe) var _authenticateFromClosure: ((URL, String?, [String: String]?) async throws -> URL)!
}
