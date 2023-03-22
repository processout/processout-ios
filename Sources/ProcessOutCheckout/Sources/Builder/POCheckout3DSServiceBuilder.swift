//
//  POCheckout3DSServiceBuilder.swift
//  ProcessOutCheckout
//
//  Created by Andrii Vysotskyi on 01.03.2023.
//

import Foundation
import ProcessOut

public final class POCheckout3DSServiceBuilder {

    /// - NOTE: Delegate will be strongly referenced by created service.
    public static func with(delegate: POCheckout3DSServiceDelegate) -> POCheckout3DSServiceBuilder {
        Self(delegate: delegate)
    }

    public func build() -> PO3DSServiceType {
        Checkout3DSService(errorMapper: AuthenticationErrorMapper(), delegate: delegate)
    }

    // MARK: -

    private init(delegate: POCheckout3DSServiceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Private Properties

    private let delegate: POCheckout3DSServiceDelegate
}
