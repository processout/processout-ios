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

        /// APM redirect information.
        static let redirectWarning = POStringResource("dynamic-checkout.redirect-warning", comment: "")

        /// Text to use with divider separating different sections.
        static let sectionsDivider = POStringResource("dynamic-checkout.sections-divider", comment: "")
    }
}

// swiftlint:enable nesting
