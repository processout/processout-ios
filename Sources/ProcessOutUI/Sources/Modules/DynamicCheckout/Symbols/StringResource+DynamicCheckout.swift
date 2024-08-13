//
//  StringResource+DynamicCheckout.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.04.2024.
//

// swiftlint:disable nesting

extension StringResource {

    enum DynamicCheckout {

        enum Button {

            /// Submit button title.
            static let pay = StringResource("dynamic-checkout.pay-button", comment: "")

            /// Cancel button title.
            static let cancel = StringResource("dynamic-checkout.cancel-button", comment: "")
        }

        enum CancelConfirmation {

            /// Success message.
            static let title = StringResource("cancel-confirmation.title", comment: "")

            /// Confirm button title..
            static let confirm = StringResource("cancel-confirmation.confirm", comment: "")

            /// Cancel button title.
            static let cancel = StringResource("cancel-confirmation.cancel", comment: "")
        }

        enum Error {

            /// Indicates that implementation is unable to process payment.
            static let generic = StringResource("dynamic-checkout.error.generic", comment: "")

            /// Indicates that selected payment method is no longer available.
            static let methodUnavailable = StringResource("dynamic-checkout.error.method-unavailable", comment: "")
        }

        enum Warning {

            /// APM redirect information.
            static let redirect = StringResource("dynamic-checkout.redirect-warning", comment: "")
        }

        /// Success message.
        static let successMessage = StringResource("dynamic-checkout.success-message", comment: "")
    }
}

// swiftlint:enable nesting
