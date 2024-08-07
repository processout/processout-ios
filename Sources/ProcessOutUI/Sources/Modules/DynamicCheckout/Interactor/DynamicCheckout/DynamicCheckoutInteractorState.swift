//
//  DynamicCheckoutInteractorState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 05.03.2024.
//

@_spi(PO) import ProcessOut
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
        let pkPaymentRequests: [String: PKPaymentRequest]

        /// Defines whether payment is cancellable.
        let isCancellable: Bool

        /// Current invoice.
        var invoice: POInvoice

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

        /// Card tokenization interactor.
        let cardTokenizationInteractor: (any CardTokenizationInteractor)?

        /// Native APM interactor.
        let nativeAlternativePaymentInteractor: (any NativeAlternativePaymentInteractor)?

        /// Submission state.
        var submission: PaymentSubmission

        /// Defines whether payment is cancellable.
        var isCancellable: Bool

        /// Indicates whether cancellation was forced (if at all).
        var isForcelyCancelled = false

        /// For payment methods that need preloading this is initially set to `false`. Default value is `true`.
        var isReady = true

        /// Boolean flag indicating whether interactor is currently processing native APM and it is
        /// in `awaitingCapture` state
        ///
        /// Normally consumer of state should be able to inspect interactor state directly, but since it is not
        /// currently possible because state update is perform on `willChange`.
        var isAwaitingNativeAlternativePaymentCapture = false // swiftlint:disable:this identifier_name

        /// Payment method that should be selected in case of processing failure.
        var pendingPaymentMethodId: String?

        /// When processing fails and this property is set to `true`, pending payment method (if present) is
        /// started after selection.
        var shouldStartPendingPaymentMethod = false

        /// Boolean value indicating whether invoice should be invalidated when interactor transitions back
        /// to started from this state.
        var shouldInvalidateInvoice = false
    }

    enum PaymentSubmission {

        /// Submission is currently unavailable.
        case temporarilyUnavailable

        /// Submission is currently possible.
        case possible

        /// Payment is already being processed.
        case submitting
    }

    struct Recovering {

        /// Failure that caused recovery process to happen.
        let failure: POFailure

        /// Started state snapshot.
        let snapshot: Started

        /// Failed payment method ID.
        let failedPaymentMethodId: String

        /// Payment method that should be selected in case of processing failure.
        var pendingPaymentMethodId: String?

        /// When processing fails and this property is set to `true`, pending payment method (if present) is
        /// started after selection.
        var shouldStartPendingPaymentMethod = false
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

    /// Payment recovering state.
    case recovering(Recovering)

    /// Failure state. This is a sink state.
    case failure(POFailure)

    /// Payment was successfully processed. This is a sink state.
    case success
}
