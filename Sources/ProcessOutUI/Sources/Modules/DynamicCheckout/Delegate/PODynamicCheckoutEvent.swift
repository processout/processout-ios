//
//  PODynamicCheckoutEvent.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.02.2024.
//

import ProcessOut

/// Events emitted by dynamic checkout module during its lifecycle.
public enum PODynamicCheckoutEvent {

    /// Initial event that is sent prior any other event.
    case willStart

    /// Indicates that implementation successfully loaded initial portion of data and currently waiting for user
    /// to fulfil needed info.
    case didStart

    /// Invoked when users changes payment method selection.
    case didSelectPaymentMethod

    /// Event is sent after payment was confirmed to be captured. This is a final event.
    case didCompletePayment

    /// Event is sent in case unretryable error occurs. This is a final event.
    case didFail(failure: POFailure)
}
