//
//  StringResource+CardScanner.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

@_spi(PO) import ProcessOut

extension POStringResource {

    enum CardScanner {

        enum DeniedAuthorization { // swiftlint:disable:this nesting

            /// Confirmation title.
            static let title = POStringResource("card-scanner.denied-authorization.title", comment: "")

            /// Confirmation message.
            static let message = POStringResource("card-scanner.denied-authorization.message", comment: "")

            /// Open settings button title..
            static let openSettings = POStringResource("card-scanner.denied-authorization.open-settings", comment: "")

            /// Cancel button title.
            static let cancel = POStringResource("card-scanner.denied-authorization.cancel", comment: "")
        }

        /// Card scanner title.
        static let title = POStringResource("card-scanner.title", comment: "")

        /// Card scanner description.
        static let description = POStringResource("card-scanner.description", comment: "")

        /// Cancel button title.
        static let cancelButton = POStringResource("card-scanner.cancel-button", comment: "")
    }
}
