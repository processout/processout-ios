//
//  Mock3DSService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.04.2023.
//

// swiftlint:disable identifier_name line_length

import Foundation
@testable @_spi(PO) import ProcessOut

final class Mock3DSService: PO3DSService, Sendable {

    var authenticationRequestParametersCallsCount: Int {
        lock.withLock { _authenticationRequestParametersCallsCount }
    }

    var authenticationRequestParametersFromClosure: ((PO3DS2Configuration) throws -> PO3DS2AuthenticationRequestParameters)! {
        get { lock.withLock { _authenticationRequestParametersFromClosure } }
        set { lock.withLock { _authenticationRequestParametersFromClosure = newValue } }
    }

    var performChallengeCallsCount: Int {
        lock.withLock { _performChallengeCallsCount }
    }

    var performChallengeFromClosure: ((PO3DS2ChallengeParameters) throws -> PO3DS2ChallengeResult)! {
        get { lock.withLock { _performChallengeFromClosure } }
        set { lock.withLock { _performChallengeFromClosure = newValue } }
    }

    // MARK: - PO3DSService

    func authenticationRequestParameters(
        configuration: PO3DS2Configuration
    ) async throws -> PO3DS2AuthenticationRequestParameters {
        try lock.withLock {
            _authenticationRequestParametersCallsCount += 1
            return try _authenticationRequestParametersFromClosure(configuration)
        }
    }

    func performChallenge(with parameters: PO3DS2ChallengeParameters) async throws -> PO3DS2ChallengeResult {
        try lock.withLock {
            _performChallengeCallsCount += 1
            return try _performChallengeFromClosure(parameters)
        }
    }

    // MARK: - Private Properties

    private let lock = POUnfairlyLocked()

    private nonisolated(unsafe) var _authenticationRequestParametersCallsCount = 0
    private nonisolated(unsafe) var _authenticationRequestParametersFromClosure: ((PO3DS2Configuration) throws -> PO3DS2AuthenticationRequestParameters)!

    private nonisolated(unsafe) var _performChallengeCallsCount = 0
    private nonisolated(unsafe) var _performChallengeFromClosure: ((PO3DS2ChallengeParameters) throws -> PO3DS2ChallengeResult)!
}

// swiftlint:enable identifier_name line_length
