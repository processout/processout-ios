//
//  POStringResource+NativeAlternativePayment.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

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

        enum Error {

            /// Email is not valid.
            static let invalidEmail = StringResource("native-alternative-payment.error.invalid-email", comment: "")

            /// Plural format key: "%#@length@"
            static let invalidLength = StringResource(
                "native-alternative-payment.error.invalid-length-%d", comment: ""
            )

            /// Number is not valid.
            static let invalidNumber = StringResource("native-alternative-payment.error.invalid-number", comment: "")

            /// Phone number is not valid.
            static let invalidPhone = StringResource("native-alternative-payment.error.invalid-phone", comment: "")

            /// Value is not valid.
            static let invalidValue = StringResource("native-alternative-payment.error.invalid-value", comment: "")

            /// Parameter is required.
            static let requiredParameter = StringResource(
                "native-alternative-payment.error.required-parameter", comment: ""
            )
        }

        enum CancelConfirmation {

            /// Success message.
            static let title = StringResource("cancel-confirmation.title", comment: "")

            /// Confirm button title..
            static let confirm = StringResource("cancel-confirmation.confirm", comment: "")

            /// Cancel button title.
            static let cancel = StringResource("cancel-confirmation.cancel", comment: "")
        }
    }
}

// swiftlint:enable nesting
