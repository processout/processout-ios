//
//  POCheckoutThreeDSHandlerBuilder.swift
//  ProcessOutCheckout
//
//  Created by Andrii Vysotskyi on 01.03.2023.
//

import Foundation
@_spi(PO) import ProcessOut

@_spi(PO)
public final class POCheckoutThreeDSHandlerBuilder {

    public static func with(delegate: POCheckoutThreeDSHandlerDelegate) -> POCheckoutThreeDSHandlerBuilder {
        Self(delegate: delegate)
    }

    public func build() -> PO3DSServiceType {
        CheckoutThreeDSHandler(errorMapper: AuthenticationErrorMapper(), delegate: delegate)
    }

    // MARK: -

    private init(delegate: POCheckoutThreeDSHandlerDelegate) {
        self.delegate = delegate
    }

    // MARK: - Private Properties

    private let delegate: POCheckoutThreeDSHandlerDelegate
}
