//
//  POStringResource+NativeAlternativePayment.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

@_spi(PO) import ProcessOut

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

            /// Capture confirmation.
            static let confirmCapture = POStringResource(
                "native-alternative-payment.confirm-capture-button.title", comment: ""
            )

            /// Save barcode button.
            static let saveBarcode = POStringResource(
                "native-alternative-payment.save-barcode-button.title", comment: ""
            )

            /// Cancel button title.
            static let cancel = POStringResource("native-alternative-payment.cancel-button.title", comment: "")
        }

        enum Success {

            /// Success message.
            static let message = POStringResource("native-alternative-payment.success.message", comment: "")
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

        enum BarcodeError {

            /// Error title.
            static let title = POStringResource("native-alternative-payment.barcode-error.title", comment: "")

            /// Error message.
            static let message = POStringResource("native-alternative-payment.barcode-error.message", comment: "")

            /// Confirm button.
            static let confirm = POStringResource("native-alternative-payment.barcode-error.confirm", comment: "")
        }

        enum CancelConfirmation {

            /// Success message.
            static let title = POStringResource("cancel-confirmation.title", comment: "")

            /// Confirm button title..
            static let confirm = POStringResource("cancel-confirmation.confirm", comment: "")

            /// Cancel button title.
            static let cancel = POStringResource("cancel-confirmation.cancel", comment: "")
        }
    }
}

// swiftlint:enable nesting
