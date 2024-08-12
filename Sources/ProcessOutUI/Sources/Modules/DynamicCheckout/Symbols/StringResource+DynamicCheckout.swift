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

            /// Submit button title.
            static let pay = POStringResource("dynamic-checkout.pay-button", comment: "")

            /// Cancel button title.
            static let cancel = POStringResource("dynamic-checkout.cancel-button", comment: "")
        }

        enum CancelConfirmation {

            /// Success message.
            static let title = POStringResource("cancel-confirmation.title", comment: "")

            /// Confirm button title..
            static let confirm = POStringResource("cancel-confirmation.confirm", comment: "")

            /// Cancel button title.
            static let cancel = POStringResource("cancel-confirmation.cancel", comment: "")
        }

        enum Error {

            /// Indicates that implementation is unable to process payment.
            static let generic = POStringResource("dynamic-checkout.error.generic", comment: "")

            /// Indicates that selected payment method is no longer available.
            static let methodUnavailable = POStringResource("dynamic-checkout.error.method-unavailable", comment: "")
        }

        enum Warning {

            /// APM redirect information.
            static let redirect = POStringResource("dynamic-checkout.redirect-warning", comment: "")
        }

        /// Success message.
        static let successMessage = POStringResource("dynamic-checkout.success-message", comment: "")
    }
}

// swiftlint:enable nesting
