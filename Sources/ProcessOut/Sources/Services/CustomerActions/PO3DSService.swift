//
//  PO3DSService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

@available(*, deprecated, renamed: "PO3DSService")
public typealias PO3DSServiceType = PO3DSService

/// This interface provides methods to process 3-D Secure transactions.
public protocol PO3DSService: AnyObject {

    /// Asks implementation to create request that will be passed to 3DS Server to create the AReq.
    func authenticationRequest(
        configuration: PO3DS2Configuration,
        completion: @escaping (Result<PO3DS2AuthenticationRequestParameters, POFailure>) -> Void
    )

    /// Implementation must handle given 3DS2 challenge and call completion with result. Use `true` if challenge
    /// was handled successfully, if transaction was denied, pass `false`. In all other cases, call completion
    /// with failure indicating what went wrong.
    func handle(challenge: PO3DS2ChallengeParameters, completion: @escaping (Result<Bool, POFailure>) -> Void)

    /// Asks implementation to handle redirect. If value of ``PO3DSRedirect/timeout`` is present it must be
    /// respected, meaning if timeout is reached `completion` should be called with instance of ``POFailure`` with
    /// ``POFailure/code-swift.property`` set to ``POFailure/TimeoutCode/mobile``.
    @available(*, deprecated, message: "Redirects are handled internally.")
    func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void)
}

@MainActor
extension PO3DSService {

    /// Asks implementation to create request that will be passed to 3DS Server to create the AReq.
    func authenticationRequest(
        configuration: PO3DS2Configuration
    ) async throws -> PO3DS2AuthenticationRequestParameters {
        try await withUnsafeThrowingContinuation { continuation in
            authenticationRequest(configuration: configuration) { continuation.resume(with: $0) }
        }
    }

    /// Implementation must handle given 3DS2 challenge and call completion with result. Use `true` if challenge
    /// was handled successfully, if transaction was denied, pass `false`. In all other cases, call completion
    /// with failure indicating what went wrong.
    func handle(challenge: PO3DS2ChallengeParameters) async throws -> Bool {
        try await withUnsafeThrowingContinuation { continuation in
            handle(challenge: challenge) { continuation.resume(with: $0) }
        }
    }

    @available(*, deprecated, message: "Redirects are handled internally.")
    func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
        let failure = POFailure(message: "Unexpected method invocation.", code: .generic(.mobile))
        completion(.failure(failure))
    }
}
