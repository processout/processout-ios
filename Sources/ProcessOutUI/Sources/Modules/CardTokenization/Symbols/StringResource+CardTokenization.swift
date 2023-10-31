//
//  StringResource+CardTokenization.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.10.2023.
//

// swiftlint:disable nesting

extension StringResource {

    enum CardTokenization {

        /// Card tokenization title.
        static let title = StringResource("card-tokenization.title", tableName: "ProcessOutUI", comment: "")

        enum CardDetails {

            /// Card details section title.
            static let title = StringResource(
                "card-tokenization.card-details.title", tableName: "ProcessOutUI", comment: ""
            )

            enum Placeholder {

                /// Card number placeholder.
                static let number = StringResource(
                    "card-tokenization.card-details.number.placeholder", tableName: "ProcessOutUI", comment: ""
                )

                /// Card expiration placeholder.
                static let expiration = StringResource(
                    "card-tokenization.card-details.expiration.placeholder", tableName: "ProcessOutUI", comment: ""
                )

                /// Card CVC placeholder.
                static let cvc = StringResource(
                    "card-tokenization.card-details.cvc.placeholder", tableName: "ProcessOutUI", comment: ""
                )

                /// Cardholder name placeholder.
                static let cardholder = StringResource(
                    "card-tokenization.card-details.cardholder.placeholder", tableName: "ProcessOutUI", comment: ""
                )
            }
        }

        enum PreferredScheme {

            /// Preferred scheme section title.
            static let title = StringResource(
                "card-tokenization.preferred-scheme.title", tableName: "ProcessOutUI", comment: ""
            )
        }

        enum BillingAddress {

            /// Billing address section title.
            static let title = StringResource(
                "card-tokenization.billing-address.title", tableName: "ProcessOutUI", comment: ""
            )

            /// Billing address street.
            static let street = StringResource(
                "card-tokenization.billing-address.street", tableName: "ProcessOutUI", comment: ""
            )
        }

        enum Error {

            /// Generic card error.
            static let card = StringResource("card-tokenization.error.card", tableName: "ProcessOutUI", comment: "")

            /// Invalid card number.
            static let cardNumber = StringResource(
                "card-tokenization.error.card-number", tableName: "ProcessOutUI", comment: ""
            )

            /// Invalid card expiration.
            static let cardExpiration = StringResource(
                "card-tokenization.error.card-expiration", tableName: "ProcessOutUI", comment: ""
            )

            /// Invalid card track data.
            static let trackData = StringResource(
                "card-tokenization.error.track-data", tableName: "ProcessOutUI", comment: ""
            )

            /// Invalid CVC.
            static let cvc = StringResource("card-tokenization.error.cvc", tableName: "ProcessOutUI", comment: "")

            /// Invalid cardholder name.
            static let cardholderName = StringResource(
                "card-tokenization.error.cardholder-name", tableName: "ProcessOutUI", comment: ""
            )

            /// Generic error description.
            static let generic = StringResource(
                "card-tokenization.error.generic", tableName: "ProcessOutUI", comment: ""
            )
        }

        enum Button {

            /// Submit button title.
            static let submit = StringResource(
                "card-tokenization.submit-button.title", tableName: "ProcessOutUI", comment: ""
            )

            /// Cancel button title.
            static let cancel = StringResource(
                "card-tokenization.cancel-button.title", tableName: "ProcessOutUI", comment: ""
            )
        }
    }
}

// swiftlint:enable nesting
