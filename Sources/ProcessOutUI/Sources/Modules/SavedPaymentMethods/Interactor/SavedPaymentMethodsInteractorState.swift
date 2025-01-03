//
//  SavedPaymentMethodsInteractorState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.12.2024.
//

import ProcessOut

enum SavedPaymentMethodsInteractorState {

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

        /// Customer tokens that are being removed and associated tasks.
        let removedCustomerTokenId: String

        /// Associated removal task.
        let task: Task<Void, Never>

        /// Payment methods that are pending removal.
        var pendingRemovalCustomerTokenIds: [String]
    }

    struct PaymentMethod {

        /// Customer token ID.
        let customerTokenId: String

        /// Payment method's logo.
        let logo: POImageRemoteResource

        /// Name.
        let name: String

        /// Description.
        let description: String?
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
