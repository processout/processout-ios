//
//  DynamicCheckoutInteractorState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 05.03.2024.
//

import ProcessOut

enum DynamicCheckoutInteractorState {

    struct Started {

        /// Express payment methods.
        let paymentMethods: [String: PODynamicCheckoutPaymentMethod]

        /// Express payment methods.
        let expressPaymentMethodIds: [String]

        /// Payment methods.
        let regularPaymentMethodIds: [String]

        /// Defines whether payment is cancellable.
        var isCancellable: Bool

        /// Most recent error description if any.
        var recentErrorDescription: String?
    }

    enum PaymentSubmission {

        /// Payment submission can't be forced.
        case unavailable

        /// Submission is currently unavailable.
        case temporarilyUnavailable

        /// Submission is currently possible.
        case possible

        /// Payment is already being processed.
        case submitting
    }

    // todo(andrii-vystoskyi): add card payment coordinator
    struct PaymentProcessing {

        /// Started state snapshot.
        let snapshot: Started

        /// Payment method ID that is currently being processed.
        let paymentMethodId: String

        /// Submission state.
        var submission: PaymentSubmission

        /// Defines whether payment is cancellable.
        var isCancellable: Bool
    }

    /// Idle state.
    case idle

    /// Starting state.
    case starting

    /// Started state.
    case started(Started)

    /// Payment is being processed.
    case paymentProcessing(PaymentProcessing)

    /// Failure state. This is a sink state.
    case failure(POFailure)

    /// Payment was successfuly processed. This is a sink state.
    case success
}
