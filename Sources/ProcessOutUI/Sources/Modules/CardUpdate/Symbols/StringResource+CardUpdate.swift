//
//  StringResource+CardUpdate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

// swiftlint:disable nesting

extension StringResource {

    enum CardUpdate {

        /// Card update title.
        static let title = StringResource("card-update.title", comment: "")

        enum Button {

            /// Submit button title.
            static let submit = StringResource("card-update.submit-button.title", comment: "")

            /// Cancel button title.
            static let cancel = StringResource("card-update.cancel-button.title", comment: "")
        }

        enum Error {

            /// Invalid CVC.
            static let cvc = StringResource("card-update.error.cvc", comment: "")

            /// Generic error description.
            static let generic = StringResource("card-update.error.generic", comment: "")
        }
    }
}

// swiftlint:enable nesting