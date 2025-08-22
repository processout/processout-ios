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
public struct POSavedPaymentMethodsConfiguration {

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
    public struct CancelButton {

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

    /// Invoice request.
    /// - NOTE: Make sure that client secret is set to ensures that payment methods saved by the customer are
    /// included in the response.
    public let invoiceRequest: POInvoiceRequest

    /// Custom title. Use empty string to hide title.
    public let title: String?

    /// Single payment method configuration.
    public let paymentMethod: PaymentMethod

    /// Cancel button. To remove button use `nil`.
    public let cancelButton: CancelButton?

    /// Localization configuration. Defaults to device localization.
    public let localization: LocalizationConfiguration

    public init(
        invoiceRequest: POInvoiceRequest,
        title: String? = nil,
        paymentMethod: PaymentMethod = .init(deleteButton: .init()),
        cancelButton: CancelButton? = .init(),
        localization: LocalizationConfiguration = .device()
    ) {
        self.invoiceRequest = invoiceRequest
        self.title = title
        self.paymentMethod = paymentMethod
        self.cancelButton = cancelButton
        self.localization = localization
    }
}
