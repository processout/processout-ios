//
//  NativeAlternativePaymentCancelationReason.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.08.2026.
//

import Foundation

/// Describes the reason why the payment flow was cancelled.
enum NativeAlternativePaymentCancelationReason {

    /// The customer explicitly cancelled the payment flow (for example, by tapping a Cancel button).
    case customer

    /// The payment flow was cancelled because the associated objects were released as part of the
    /// lifecycle.
    ///
    /// This commonly happens when the screen is dismissed, but it can also occur for other reasons
    /// that result in the flow being deallocated.
    case lifecycle

    /// The payment flow was explicitly cancelled by the application code.
    case programmatic
}
