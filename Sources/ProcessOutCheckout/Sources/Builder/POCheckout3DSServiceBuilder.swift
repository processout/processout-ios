//
//  POCheckout3DSServiceBuilder.swift
//  ProcessOutCheckout
//
//  Created by Andrii Vysotskyi on 01.03.2023.
//

import Foundation
import ProcessOut
import Checkout3DS

/// Builder to configure and create service capable of handling 3DS challenges using Checkout3DS SDK.
public final class POCheckout3DSServiceBuilder {

    /// - NOTE: Delegate will be strongly referenced by created service.
    public static func with(delegate: POCheckout3DSServiceDelegate) -> POCheckout3DSServiceBuilder {
        Self(delegate: delegate)
    }

    public func with(environment: Checkout3DS.Environment) -> POCheckout3DSServiceBuilder {
        self.environment = environment
        return self
    }

    /// Creates service instance.
    public func build() -> PO3DSService {
        Checkout3DSService(
            errorMapper: DefaultAuthenticationErrorMapper(),
            configurationMapper: DefaultConfigurationMapper(),
            delegate: delegate,
            environment: environment
        )
    }

    // MARK: -

    private init(delegate: POCheckout3DSServiceDelegate) {
        self.delegate = delegate
        environment = .production
    }

    // MARK: - Private Properties

    private let delegate: POCheckout3DSServiceDelegate
    private var environment: Checkout3DS.Environment
}
