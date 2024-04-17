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

            /// Submit button.
            static let submit = POStringResource("dynamic-checkout.submit-button", comment: "")

            /// Cancel button title.
            static let cancel = POStringResource("dynamic-checkout.cancel-button", comment: "")
        }
    }
}

// swiftlint:enable nesting
