//
//  POCheckoutThreeDSHandlerDelegate.swift
//  ProcessOutCheckout
//
//  Created by Andrii Vysotskyi on 01.03.2023.
//

@_spi(PO) import ProcessOut
import Checkout3DS

@_spi(PO)
public protocol POCheckoutThreeDSHandlerDelegate: AnyObject { // POCheckout3DS2ServiceDelegate

    /// Notifies delegate that handler is about to fingerprint device. Implementation should create
    /// `ThreeDS2ServiceConfiguration` using `configParameters` and return it.
    func willFingerprintDevice(
        parameters: Checkout3DS.ThreeDS2ServiceConfiguration.ConfigParameters
    ) -> Checkout3DS.ThreeDS2ServiceConfiguration

    /// Asks delegate whether handler should continue fingerprinting. Completion should be called with
    /// `true` if fingerprinting should be continued, use `false` otherwise. Default implementation
    /// ignores warnings and completes with `true`.
    /// - NOTE: Completion must be called on main thread.
    func shouldContinueFingerprinting(warnings: Set<Checkout3DS.Warning>, completion: @escaping (Bool) -> Void)

    /// Asks delegate to redirect user using given context.
    func redirect(context: PO3DSRedirectContext, completion: @escaping (Result<String, POFailure>) -> Void)
}

extension POCheckoutThreeDSHandlerDelegate {

    func shouldContinueFingerprinting(warnings: Set<Checkout3DS.Warning>, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}
