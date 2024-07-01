//
//  StringResource+CardUpdate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

@_spi(PO) import ProcessOut

// swiftlint:disable nesting

extension POStringResource {

    enum CardUpdate {

        /// Card update title.
        static let title = POStringResource("card-update.title", comment: "")

        enum CardDetails {

            /// Card CVC placeholder.
            static let cvc = POStringResource("card-update.cvc", comment: "")
        }

        enum PreferredScheme {

            /// Preferred scheme section title.
            static let title = POStringResource("card-update.preferred-scheme", comment: "")
        }

        enum Button {

            /// Submit button title.
            static let submit = POStringResource("card-update.submit-button", comment: "")

            /// Cancel button title.
            static let cancel = POStringResource("card-update.cancel-button", comment: "")
        }

        enum Error {

            /// Invalid CVC.
            static let cvc = POStringResource("card-update.error.cvc", comment: "")

            /// Generic error description.
            static let generic = POStringResource("card-update.error.generic", comment: "")
        }
    }
}

// swiftlint:enable nesting
