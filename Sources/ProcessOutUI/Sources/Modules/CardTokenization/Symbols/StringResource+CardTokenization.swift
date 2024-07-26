//
//  POStringResource+CardTokenization.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.10.2023.
//

// swiftlint:disable nesting

extension StringResource {

    enum CardTokenization {

        /// Card tokenization title.
        static let title = StringResource("card-tokenization.title", comment: "")

        enum CardDetails {

            /// Card number placeholder.
            static let number = StringResource("card-tokenization.card-details.number.placeholder", comment: "")

            /// Card expiration placeholder.
            static let expiration = StringResource(
                "card-tokenization.card-details.expiration.placeholder", comment: ""
            )

            /// Card CVC placeholder.
            static let cvc = StringResource("card-tokenization.card-details.cvc.placeholder", comment: "")

            /// Cardholder name placeholder.
            static let cardholder = StringResource(
                "card-tokenization.card-details.cardholder.placeholder", comment: ""
            )
        }

        enum PreferredScheme {

            /// Preferred scheme section title.
            static let title = StringResource("card-tokenization.preferred-scheme.title", comment: "")
        }

        enum BillingAddress {

            /// Billing address section title.
            static let title = StringResource("card-tokenization.billing-address.title", comment: "")

            /// Billing address street.
            static let street = StringResource("card-tokenization.billing-address.street", comment: "")
        }

        enum Error {

            /// Generic card error.
            static let card = StringResource("card-tokenization.error.card", comment: "")

            /// Invalid card number.
            static let cardNumber = StringResource("card-tokenization.error.card-number", comment: "")

            /// Invalid card expiration.
            static let cardExpiration = StringResource("card-tokenization.error.card-expiration", comment: "")

            /// Invalid card track data.
            static let trackData = StringResource("card-tokenization.error.track-data", comment: "")

            /// Invalid CVC.
            static let cvc = StringResource("card-tokenization.error.cvc", comment: "")

            /// Invalid cardholder name.
            static let cardholderName = StringResource("card-tokenization.error.cardholder-name", comment: "")

            /// Generic error description.
            static let generic = StringResource("card-tokenization.error.generic", comment: "")
        }

        enum Button {

            /// Submit button title.
            static let submit = StringResource("card-tokenization.submit-button.title", comment: "")

            /// Cancel button title.
            static let cancel = StringResource("card-tokenization.cancel-button.title", comment: "")
        }
    }
}

// swiftlint:enable nesting
