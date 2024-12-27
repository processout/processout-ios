//
//  SavedPaymentMethodsViewModelState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

import ProcessOut

struct SavedPaymentMethodsViewModelState {

    struct PaymentMethod: Identifiable {

        /// Section ID.
        let id: String

        /// Payment method's logo.
        let logo: POImageRemoteResource

        /// Name.
        let name: String

        /// Description.
        let description: String?

        /// Requests payment method removal.
        let delete: () -> Void
    }

    /// Available payment methods.
    let paymentMethods: [PaymentMethod]
}

extension SavedPaymentMethodsViewModelState: AnimationIdentityProvider {

    var animationIdentity: AnyHashable {
        [paymentMethods.map(\.id)]
    }

    static var idle: SavedPaymentMethodsViewModelState {
        .init(paymentMethods: [])
    }
}
