//
//  PODynamicCheckoutEvent.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.02.2024.
//

import ProcessOut

/// Events emitted by dynamic checkout module during its lifecycle.
@_spi(PO)
public enum PODynamicCheckoutEvent: Sendable {

    /// Initial event that is sent prior any other event.
    case willStart

    /// Indicates that implementation successfully loaded initial portion of data and currently waiting for user
    /// to fulfil needed info.
    case didStart

    /// Invoked when users requests selection of another payment method.
    case willSelectPaymentMethod

    /// Event is sent after payment was confirmed to be captured. This is a final event.
    case didCompletePayment

    /// Event is sent in case unretryable error occurs. This is a final event.
    case didFail(failure: POFailure)

    /// Placeholder to allow adding additional events while staying backward compatible.
    /// - Warning: Don't match this case directly, instead use default.
    @_spi(PO)
    case unknown
}
