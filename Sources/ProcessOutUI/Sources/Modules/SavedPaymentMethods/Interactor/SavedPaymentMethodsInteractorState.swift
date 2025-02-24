//
//  SavedPaymentMethodsInteractorState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.12.2024.
//

@_spi(PO) import ProcessOut

enum SavedPaymentMethodsInteractorState {

    typealias PaymentMethod = PODynamicCheckoutPaymentMethod.CustomerToken

    struct Starting {

        /// Associated starting task.
        let task: Task<Void, Never>
    }

    struct Started {

        /// Saved payment methods.
        let paymentMethods: [PaymentMethod]

        /// Customer ID.
        let customerId: String

        /// Recent failure.
        var recentFailure: POFailure?
    }

    struct Removing {

        /// Started state snapshot.
        let startedStateSnapshot: Started

        /// Payment method that is currently being removed.
        let removedPaymentMethod: PaymentMethod

        /// Associated removal task.
        let task: Task<Void, Never>

        /// Payment methods that are pending removal.
        var pendingRemovalCustomerTokenIds: [String]
    }

    case idle, starting(Starting), started(Started), removing(Removing), completed(Result<Void, POFailure>)
}

extension SavedPaymentMethodsInteractorState: InteractorState {

    var isSink: Bool {
        switch self {
        case .completed:
            return true
        default:
            return false
        }
    }
}
