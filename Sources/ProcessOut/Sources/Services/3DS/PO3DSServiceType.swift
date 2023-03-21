//
//  PO3DSServiceType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

/// This interface provides methods to process 3-D Secure transactions.
public protocol PO3DSServiceType: AnyObject {

    /// Asks implementation to create request that will be passed to 3DS Server to create the AReq.
    func authenticationRequest(
        configuration: PO3DS2Configuration,
        completion: @escaping (Result<PO3DS2AuthenticationRequest, POFailure>) -> Void
    )

    /// Implementation must handle given 3DS2 challenge and call completion with result. Use `true` if challenge
    /// was handled successfully, if transaction was denied, pass `false`. In all other cases, call completion
    /// with failure indicating what went wrong.
    func handle(challenge: PO3DS2Challenge, completion: @escaping (Result<Bool, POFailure>) -> Void)

    /// Asks implementation to handle redirect. If value of ``PO3DSRedirect/timeout`` is present it must be
    /// respected, meaning if timeout is reached `completion` should be called with instance of ``POFailure`` with
    /// ``POFailure/code-swift.property`` set to ``POFailure/TimeoutCode/mobile``.
    func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void)
}
