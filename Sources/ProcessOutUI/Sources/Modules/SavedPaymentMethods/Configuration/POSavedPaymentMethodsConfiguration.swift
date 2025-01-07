//
//  POSavedPaymentMethodsConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.12.2024.
//

import SwiftUI
import ProcessOut

/// Saved payment methods configuration.
@MainActor
public struct POSavedPaymentMethodsConfiguration: Sendable {

    @MainActor
    public struct PaymentMethod {

        /// Payment method's delete button.
        public let deleteButton: DeleteButton

        public init(deleteButton: DeleteButton = .init()) {
            self.deleteButton = deleteButton
        }
    }

    @MainActor
    public struct DeleteButton {

        /// Cancel button title. Use `nil` for default title.
        public let title: String?

        /// Button icon. 
        public let icon: AnyView?

        /// When property is set implementation asks user to confirm removal.
        public let confirmation: POConfirmationDialogConfiguration?

        public init(
            title: String? = nil,
            icon: (some View)? = AnyView?.none,
            confirmation: POConfirmationDialogConfiguration? = nil
        ) {
            self.title = title
            self.icon = icon.map(AnyView.init(erasing:))
            self.confirmation = confirmation
        }
    }

    @MainActor
    public struct CancelButton: Sendable {

        /// Cancel button title. Use `nil` for default title.
        public let title: String?

        /// Button icon.
        public let icon: AnyView?

        /// When property is set implementation asks user to confirm cancel.
        public let confirmation: POConfirmationDialogConfiguration?

        public init(
            title: String? = nil,
            icon: (some View)? = AnyView?.none,
            confirmation: POConfirmationDialogConfiguration? = nil
        ) {
            self.title = title
            self.icon = icon.map(AnyView.init(erasing:))
            self.confirmation = confirmation
        }
    }

    /// Requested invoice ID.
    public let invoiceId: String

    /// A secret key associated with the client making the request.
    ///
    /// This key ensures that the payment methods saved by the customer are
    /// included in the response if the invoice has an assigned customerID.
    public let clientSecret: String

    /// Custom title. Use empty string to hide title.
    public let title: String?

    /// Single payment method configuration.
    public let paymentMethod: PaymentMethod

    /// Cancel button. To remove button use `nil`.
    public let cancelButton: CancelButton?

    public init(
        invoiceId: String,
        clientSecret: String,
        title: String? = nil,
        paymentMethod: PaymentMethod = .init(),
        cancelButton: CancelButton? = .init()
    ) {
        self.invoiceId = invoiceId
        self.clientSecret = clientSecret
        self.title = title
        self.paymentMethod = paymentMethod
        self.cancelButton = cancelButton
    }
}
