//
//  DynamicCheckoutInteractorState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 05.03.2024.
//

import ProcessOut
import PassKit

enum DynamicCheckoutInteractorState {

    struct Started {

        /// Express payment methods.
        let paymentMethods: [String: PODynamicCheckoutPaymentMethod]

        /// Express payment methods.
        let expressPaymentMethodIds: [String]

        /// Payment methods.
        let regularPaymentMethodIds: [String]

        /// Pass Kit payment request.
        let pkPaymentRequest: PKPaymentRequest?

        /// Defines whether payment is cancellable.
        var isCancellable: Bool

        /// Most recent error description if any.
        var recentErrorDescription: String?
    }

    struct Selected {

        /// Started state snapshot.
        let snapshot: Started

        /// Selected payment method ID.
        let paymentMethodId: String
    }

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

    /// Idle state.
    case idle

    /// Starting state.
    case starting

    /// Started state.
    case started(Started)

    /// There is currently selected payment method.
    case selected(Selected)

    /// Payment is being processed.
    case paymentProcessing(PaymentProcessing)

    /// Failure state. This is a sink state.
    case failure(POFailure)

    /// Payment was successfuly processed. This is a sink state.
    case success
}
