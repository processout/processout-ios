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

    public func build() -> POThreeDSHandlerType {
        let handler = CheckoutThreeDSHandler(
            errorMapper: AuthenticationErrorMapper(),
            authenticationRequestMapper: AuthenticationRequestMapper(
                decoder: JSONDecoder()
            ),
            delegate: delegate
        )
        return handler
    }

    // MARK: -

    private init(delegate: POCheckoutThreeDSHandlerDelegate) {
        self.delegate = delegate
    }

    // MARK: - Private Properties

    private let delegate: POCheckoutThreeDSHandlerDelegate
}
