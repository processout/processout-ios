//
//  Mock3DSService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.04.2023.
//

// swiftlint:disable line_length

import Foundation
@testable import ProcessOut

final class Mock3DSService: PO3DSService {

    var authenticationRequestCallsCount = 0
    var authenticationRequestFromClosure: ((PO3DS2Configuration, @escaping (Result<PO3DS2AuthenticationRequest, POFailure>) -> Void) -> Void)!
    var handleChallengeCallsCount = 0
    var handleChallengeFromClosure: ((PO3DS2Challenge, @escaping (Result<Bool, POFailure>) -> Void) -> Void)!
    var handleRedirectCallsCount = 0
    var handleRedirectFromClosure: ((PO3DSRedirect, @escaping (Result<String, POFailure>) -> Void) -> Void)!

    // MARK: - PO3DSService

    func authenticationRequest(
        configuration: PO3DS2Configuration,
        completion: @escaping (Result<PO3DS2AuthenticationRequest, POFailure>) -> Void
    ) {
        authenticationRequestCallsCount += 1
        authenticationRequestFromClosure!(configuration, completion)
    }

    func handle(challenge: PO3DS2Challenge, completion: @escaping (Result<Bool, POFailure>) -> Void) {
        handleChallengeCallsCount += 1
        handleChallengeFromClosure!(challenge, completion)
    }

    func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
        handleRedirectCallsCount += 1
        handleRedirectFromClosure!(redirect, completion)
    }
}

// swiftlint:enable line_length
