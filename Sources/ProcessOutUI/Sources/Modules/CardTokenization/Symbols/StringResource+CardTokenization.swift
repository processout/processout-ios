//
//  POStringResource+CardTokenization.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.10.2023.
//

@_spi(PO) import ProcessOut

// swiftlint:disable nesting

extension POStringResource {

    enum CardTokenization {

        /// Card tokenization title.
        static let title = POStringResource("card-tokenization.title", comment: "")

        enum CardDetails {

            /// Card number placeholder.
            static let number = POStringResource("card-tokenization.card-details.number.placeholder", comment: "")

            /// Card expiration placeholder.
            static let expiration = POStringResource(
                "card-tokenization.card-details.expiration.placeholder", comment: ""
            )

            /// Card CVC placeholder.
            static let cvc = POStringResource("card-tokenization.card-details.cvc.placeholder", comment: "")

            /// Cardholder name placeholder.
            static let cardholder = POStringResource(
                "card-tokenization.card-details.cardholder.placeholder", comment: ""
            )
        }

        enum PreferredScheme {

            /// Preferred scheme section title.
            static let title = POStringResource("card-tokenization.preferred-scheme.title", comment: "")
        }

        enum BillingAddress {

            /// Billing address section title.
            static let title = POStringResource("card-tokenization.billing-address.title", comment: "")

            /// Billing address street.
            static let street = POStringResource("card-tokenization.billing-address.street", comment: "")
        }

        enum Error {

            /// Generic card error.
            static let card = POStringResource("card-tokenization.error.card", comment: "")

            /// Invalid card number.
            static let cardNumber = POStringResource("card-tokenization.error.card-number", comment: "")

            /// Invalid card expiration.
            static let cardExpiration = POStringResource("card-tokenization.error.card-expiration", comment: "")

            /// Invalid card track data.
            static let trackData = POStringResource("card-tokenization.error.track-data", comment: "")

            /// Invalid CVC.
            static let cvc = POStringResource("card-tokenization.error.cvc", comment: "")

            /// Invalid cardholder name.
            static let cardholderName = POStringResource("card-tokenization.error.cardholder-name", comment: "")

            /// Generic error description.
            static let generic = POStringResource("card-tokenization.error.generic", comment: "")
        }

        enum Button {

            /// Card scan button title.
            static let scanCard = POStringResource("card-tokenization.scan-card.title", comment: "")

            /// Submit button title.
            static let submit = POStringResource("card-tokenization.submit-button.title", comment: "")

            /// Cancel button title.
            static let cancel = POStringResource("card-tokenization.cancel-button.title", comment: "")
        }

        /// Save card message.
        static let saveCardMessage = POStringResource("card-tokenization.save-card-message", comment: "")
    }
}

// swiftlint:enable nesting
