//
//  PO3DSService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

@available(*, deprecated, renamed: "PO3DSService")
public typealias PO3DSServiceType = PO3DSService

/// This interface provides methods to process 3-D Secure transactions.
@available(iOS, introduced: 15, deprecated, message: "Implement PO3DS2Service service directly instead.")
@_originallyDefinedIn(module: "ProcessOut", iOS 15)
public protocol PO3DSService: PO3DS2Service {

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

@available(*, deprecated, message: "Implement PO3DS2Service service directly instead.")
extension PO3DSService {

    @MainActor
    public func authenticationRequestParameters(
        configuration: PO3DS2Configuration
    ) async throws -> PO3DS2AuthenticationRequestParameters {
        try await withUnsafeThrowingContinuation { continuation in
            authenticationRequest(configuration: configuration) { continuation.resume(with: $0) }
        }
    }

    @MainActor
    public func performChallenge(with parameters: PO3DS2ChallengeParameters) async throws -> PO3DS2ChallengeResult {
        let status = try await withUnsafeThrowingContinuation { continuation in
            handle(challenge: parameters) { continuation.resume(with: $0) }
        }
        return PO3DS2ChallengeResult(transactionStatus: status)
    }

    @available(*, deprecated, message: "Redirects are handled internally.")
    public func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
        let failure = POFailure(message: "Unexpected method invocation.", code: .generic(.mobile))
        completion(.failure(failure))
    }
}
