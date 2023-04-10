//
//  POCheckout3DSServiceBuilder.swift
//  ProcessOutCheckout
//
//  Created by Andrii Vysotskyi on 01.03.2023.
//

import Foundation
import ProcessOut

/// Builder to configure and create service capable of handling 3DS challenges using Checkout3DS SDK.
public final class POCheckout3DSServiceBuilder {

    /// - NOTE: Delegate will be strongly referenced by created service.
    public static func with(delegate: POCheckout3DSServiceDelegate) -> POCheckout3DSServiceBuilder {
        Self(delegate: delegate)
    }

    /// Creates service instance.
    public func build() -> PO3DSService {
        Checkout3DSService(errorMapper: AuthenticationErrorMapper(), delegate: delegate)
    }

    // MARK: -

    private init(delegate: POCheckout3DSServiceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Private Properties

    private let delegate: POCheckout3DSServiceDelegate
}
