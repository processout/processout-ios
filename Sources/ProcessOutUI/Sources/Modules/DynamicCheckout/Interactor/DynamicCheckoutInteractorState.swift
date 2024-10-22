//
//  DynamicCheckoutInteractorState.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 05.03.2024.
//

@_spi(PO) import ProcessOut
import PassKit

enum DynamicCheckoutInteractorState {

    struct Starting {

        /// Start task.
        let task: Task<Void, Never>
    }

    struct Restarting {

        /// Payment processing state.
        let snapshot: PaymentProcessing

        /// Restart task.
        let task: Task<Void, Never>

        /// Failure that caused restart if any.
        let failure: POFailure?

        /// Payment method that should be selected in case of processing failure.
        var pendingPaymentMethodId: String?

        /// When processing fails and this property is set to `true`, pending payment method (if present) is
        /// started after selection.
        var shouldStartPendingPaymentMethod = false
    }

    struct Started {

        /// Express payment methods.
        let paymentMethods: [PODynamicCheckoutPaymentMethod]

        /// Defines whether payment is cancellable.
        let isCancellable: Bool

        /// Current invoice.
        var invoice: POInvoice

        /// Client secret.
        var clientSecret: String?

        /// Most recent error description if any.
        var recentErrorDescription: String?
    }

    struct Selected {

        /// Started state snapshot.
        let snapshot: Started

        /// Selected payment method ID.
        let paymentMethodId: String

        /// Indicates if the payment method should be saved for future use.
        /// `nil` means saving is not supported.
        var shouldSavePaymentMethod: Bool?
    }

    struct PaymentProcessing {

        /// Started state snapshot.
        let snapshot: Started

        /// Payment method ID that is currently being processed.
        let paymentMethodId: String

        /// Indicates if the current payment method will be saved. `nil` means the information is unavailable.
        let willSavePaymentMethod: Bool?

        /// Card tokenization interactor.
        let cardTokenizationInteractor: (any CardTokenizationInteractor)?

        /// Native APM interactor.
        let nativeAlternativePaymentInteractor: (any NativeAlternativePaymentInteractor)?

        /// Payment processing task if any.
        let task: Task<Void, Never>?

        /// Defines whether payment is cancellable.
        var isCancellable: Bool

        /// For payment methods that need preloading this is initially set to `false`. Default value is `true`.
        var isReady = true

        /// Boolean flag indicating whether interactor is currently processing native APM and it is
        /// in `awaitingCapture` state
        ///
        /// Normally consumer of state should be able to inspect interactor state directly, but since it is not
        /// currently possible because state update is perform on `willChange`.
        var isAwaitingNativeAlternativePaymentCapture = false // swiftlint:disable:this identifier_name

        /// Boolean value indicating whether invoice should be invalidated when interactor transitions back
        /// to started from this state.
        var shouldInvalidateInvoice = false
    }

    struct Success {

        /// Task that handles completion invocation.
        let completionTask: Task<Void, Never>
    }

    /// Idle state.
    case idle

    /// Starting state.
    case starting(Starting)

    /// Restarting state.
    case restarting(Restarting)

    /// Started state.
    case started(Started)

    /// There is currently selected payment method.
    case selected(Selected)

    /// Payment is being processed.
    case paymentProcessing(PaymentProcessing)

    /// Failure state. This is a sink state.
    case failure(POFailure)

    /// Payment was successfully processed. This is a sink state.
    case success(Success)
}

extension DynamicCheckoutInteractorState: InteractorState {

    var isSink: Bool {
        switch self {
        case .failure, .success:
            return true
        default:
            return false
        }
    }
}
