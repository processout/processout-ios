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

        enum Section {

            /// Express payment methods section title.
            static let expressMethods = POStringResource("dynamic-checkout.express-methods", comment: "")

            /// Text to use with divider separating different sections.
            static let divider = POStringResource("dynamic-checkout.sections-divider", comment: "")
        }

        /// APM redirect information.
        static let redirectWarning = POStringResource("dynamic-checkout.redirect-warning", comment: "")
    }
}

// swiftlint:enable nesting
