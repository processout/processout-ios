//
//  SavedPaymentMethodsViewModelState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

import ProcessOut
@_spi(PO) import ProcessOutCoreUI

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

        /// Payment method removal button.
        let deleteButton: POButtonViewModel
    }

    /// Available payment methods.
    let paymentMethods: [PaymentMethod]

    /// Boolean value indicating whether payment methods are being loaded.
    let isLoading: Bool
}

extension SavedPaymentMethodsViewModelState: AnimationIdentityProvider {

    var animationIdentity: AnyHashable {
        [paymentMethods.map(\.id)]
    }

    static var idle: SavedPaymentMethodsViewModelState {
        .init(paymentMethods: [], isLoading: false)
    }
}
