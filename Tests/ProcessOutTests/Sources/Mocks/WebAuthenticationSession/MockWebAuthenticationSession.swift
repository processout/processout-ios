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

    var authenticateFromClosure: ((WebAuthenticationRequest) async throws(POFailure) -> URL)! {
        get { lock.withLock { _authenticateFromClosure } }
        set { lock.withLock { _authenticateFromClosure = newValue } }
    }

    // MARK: -

    func authenticate(using request: WebAuthenticationRequest) async throws(POFailure) -> URL {
        let authenticate = lock.withLock {
            _authenticateCallsCount += 1
            return _authenticateFromClosure
        }
        return try await authenticate!(request)
    }

    // MARK: - Private Properties

    private let lock = POUnfairlyLocked()

    private nonisolated(unsafe) var _authenticateCallsCount = 0
    private nonisolated(unsafe) var _authenticateFromClosure: ((WebAuthenticationRequest) async throws(POFailure) -> URL)! // swiftlint:disable:this line_length
}
