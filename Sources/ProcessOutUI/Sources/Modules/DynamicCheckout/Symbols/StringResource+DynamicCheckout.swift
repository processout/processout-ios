//
//  StringResource+DynamicCheckout.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.04.2024.
//

@_spi(PO) import ProcessOut

// swiftlint:disable nesting

extension POStringResource {

    enum DynamicCheckout {

        enum Button {

            /// Continue button.
            static let `continue` = POStringResource("dynamic-checkout.continue-button", comment: "")

            /// Cancel button title.
            static let cancel = POStringResource("dynamic-checkout.cancel-button", comment: "")
        }

        enum CancelConfirmation {

            /// Success message.
            static let title = POStringResource("dynamic-checkout.cancel-confirmation.title", comment: "")

            /// Confirm button title..
            static let confirm = POStringResource("dynamic-checkout.cancel-confirmation.confirm", comment: "")

            /// Cancel button title.
            static let cancel = POStringResource("dynamic-checkout.cancel-confirmation.cancel", comment: "")
        }

        enum Error {

            /// Indicates that selected payment method is not available.
            static let unavailableMethod = POStringResource("dynamic-checkout.error.unavailable-method", comment: "")
        }

        /// Success message.
        static let successMessage = POStringResource("dynamic-checkout.success-message", comment: "")

        /// APM redirect information.
        static let redirectWarning = POStringResource("dynamic-checkout.redirect-warning", comment: "")
    }
}

// swiftlint:enable nesting
