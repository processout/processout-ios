//
//  StringResource+NativeAlternativePayment.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import Foundation

// swiftlint:disable nesting

extension StringResource {

    enum NativeAlternativePayment {

        /// Screen title.
        static let title = StringResource("native-alternative-payment.title", comment: "")

        enum Placeholder {

            /// Email placeholder.
            static let email = StringResource("native-alternative-payment.email.placeholder", comment: "")

            /// Phone placeholder.
            static let phone = StringResource("native-alternative-payment.phone.placeholder", comment: "")
        }

        enum Button {

            /// Pay.
            static let submit = StringResource("native-alternative-payment.submit-button.default-title", comment: "")

            /// Pay %@
            static let submitAmount = StringResource("native-alternative-payment.submit-button.title", comment: "")

            /// Cancel button title.
            static let cancel = StringResource("native-alternative-payment.cancel-button.title", comment: "")
        }

        enum Success {

            /// Success message.
            static let message = StringResource("native-alternative-payment.success.message", comment: "")
        }
    }
}

// swiftlint:enable nesting
