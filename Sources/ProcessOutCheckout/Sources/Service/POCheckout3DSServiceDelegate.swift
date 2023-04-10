//
//  POCheckout3DSServiceDelegate.swift
//  ProcessOutCheckout
//
//  Created by Andrii Vysotskyi on 01.03.2023.
//

import ProcessOut
import Checkout3DS

/// Checkout 3DS service delegate.
public protocol POCheckout3DSServiceDelegate: AnyObject {

    /// Notifies delegate that service is about to fingerprint device. Implementation should create
    /// `ThreeDS2ServiceConfiguration` using `configParameters` and return it.
    func configuration(
        with parameters: Checkout3DS.ThreeDS2ServiceConfiguration.ConfigParameters
    ) -> Checkout3DS.ThreeDS2ServiceConfiguration

    /// Asks delegate whether service should continue with given warnings. Default implementation
    /// ignores warnings and completes with `true`.
    func shouldContinue(with warnings: Set<Checkout3DS.Warning>, completion: @escaping (Bool) -> Void)

    /// Asks delegate to handle 3DS redirect. See documentation of `PO3DSService/handle(redirect:completion:)`
    /// for more details.
    func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void)
}

extension POCheckout3DSServiceDelegate {

    public func configuration(
        with parameters: Checkout3DS.ThreeDS2ServiceConfiguration.ConfigParameters
    ) -> Checkout3DS.ThreeDS2ServiceConfiguration {
        ThreeDS2ServiceConfiguration(configParameters: parameters)
    }

    public func shouldContinue(with warnings: Set<Checkout3DS.Warning>, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}
