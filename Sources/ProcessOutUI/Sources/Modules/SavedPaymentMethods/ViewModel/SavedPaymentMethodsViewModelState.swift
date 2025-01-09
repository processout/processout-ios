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
        let deleteButton: POButtonViewModel?
    }

    /// Screen title.
    let title: String?

    /// Boolean value indicating whether content is unavailable.
    let isContentUnavailable: Bool

    /// Available payment methods.
    let paymentMethods: [PaymentMethod]

    /// Boolean value indicating whether payment methods are being loaded.
    let isLoading: Bool

    /// Message if any.
    let message: POMessage?

    /// Cancel button.
    let cancelButton: POButtonViewModel?
}

extension SavedPaymentMethodsViewModelState: AnimationIdentityProvider {

    var animationIdentity: AnyHashable {
        [isContentUnavailable, paymentMethods.map(\.id), AnyHashable(cancelButton?.id), AnyHashable(message?.id)]
    }

    static var idle: SavedPaymentMethodsViewModelState {
        SavedPaymentMethodsViewModelState(
            title: nil,
            isContentUnavailable: false,
            paymentMethods: [],
            isLoading: false,
            message: nil,
            cancelButton: nil
        )
    }
}
