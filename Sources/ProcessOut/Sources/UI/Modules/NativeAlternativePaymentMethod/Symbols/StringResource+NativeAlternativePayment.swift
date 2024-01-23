//
//  StringResource+NativeAlternativePayment.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.01.2024.
//

import Foundation

// swiftlint:disable nesting

extension POStringResource {

    enum NativeAlternativePayment {

        /// Screen title.
        static let title = POStringResource("native-alternative-payment.title", comment: "")

        enum Placeholder {

            /// Email placeholder.
            static let email = POStringResource("native-alternative-payment.email.placeholder", comment: "")

            /// Phone placeholder.
            static let phone = POStringResource("native-alternative-payment.phone.placeholder", comment: "")
        }

        enum Button {

            /// Pay.
            static let submit = POStringResource("native-alternative-payment.submit-button.default-title", comment: "")

            /// Pay %@
            static let submitAmount = POStringResource("native-alternative-payment.submit-button.title", comment: "")

            /// Cancel button title.
            static let cancel = POStringResource("native-alternative-payment.cancel-button.title", comment: "")
        }

        enum Error {

            /// Email is not valid.
            static let invalidEmail = POStringResource("native-alternative-payment.error.invalid-email", comment: "")

            /// Plural format key: "%#@length@"
            static let invalidLength = POStringResource(
                "native-alternative-payment.error.invalid-length-%d", comment: ""
            )

            /// Number is not valid.
            static let invalidNumber = POStringResource("native-alternative-payment.error.invalid-number", comment: "")

            /// Phone number is not valid.
            static let invalidPhone = POStringResource("native-alternative-payment.error.invalid-phone", comment: "")

            /// Value is not valid.
            static let invalidValue = POStringResource("native-alternative-payment.error.invalid-value", comment: "")

            /// Parameter is required.
            static let requiredParameter = POStringResource(
                "native-alternative-payment.error.required-parameter", comment: ""
            )
        }

        enum Success {

            /// Success message.
            static let message = POStringResource("native-alternative-payment.success.message", comment: "")
        }
    }
}

// swiftlint:enable nesting
