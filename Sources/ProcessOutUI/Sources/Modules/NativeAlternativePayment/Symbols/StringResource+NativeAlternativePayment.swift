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

        /// Payment title.
        static let title = POStringResource("native-alternative-payment.title", comment: "")

        enum Button {

            /// Continue.
            static let `continue` = POStringResource("native-alternative-payment.continue-button.title", comment: "")

            /// Payment confirmation.
            static let confirmPayment = POStringResource(
                "native-alternative-payment.confirm-payment-button.title", comment: ""
            )

            /// Done button.
            static let done = POStringResource(
                "native-alternative-payment.done-button.title", comment: ""
            )

            /// Cancel button title.
            static let cancel = POStringResource("native-alternative-payment.cancel-button.title", comment: "")

            /// Save barcode button.
            static let saveBarcode = POStringResource(
                "native-alternative-payment.save-barcode-button.title", comment: ""
            )

            /// Copy button.
            static let copy = POStringResource("native-alternative-payment.copy-button", comment: "")

            /// Copied button.
            static let copied = POStringResource("native-alternative-payment.copied-button", comment: "")
        }

        enum Placeholder {

            /// Country placeholder.
            static let country = POStringResource("native-alternative-payment.country-placeholder", comment: "")
        }

        enum PaymentConfirmation {

            enum Progress {

                enum FirstStep {

                    /// First step title.
                    static let title = POStringResource(
                        "native-alternative-payment.payment-confirmation.progress.step1.title", comment: ""
                    )
                }

                enum SecondStep {

                    /// Second step title.
                    static let title = POStringResource(
                        "native-alternative-payment.payment-confirmation.progress.step2.title", comment: ""
                    )

                    /// Second step description.
                    static let description = POStringResource(
                        "native-alternative-payment.payment-confirmation.progress.step2.description", comment: ""
                    )
                }
            }
        }

        enum Success {

            /// Success title.
            static let title = POStringResource("native-alternative-payment.success.title", comment: "")

            /// Success message.
            static let message = POStringResource("native-alternative-payment.success.message", comment: "")
        }

        enum Error {

            /// Invalid parameter length.
            static let invalidLength = POStringResource(
                "native-alternative-payment.error.invalid-length-%d", comment: ""
            )

            /// Parameter is too short.
            static let invalidMinLength = POStringResource(
                "native-alternative-payment.error.invalid-min-length-%d", comment: ""
            )

            /// Parameter is too long.
            static let invalidMaxLength = POStringResource(
                "native-alternative-payment.error.invalid-max-length-%d", comment: ""
            )

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
    }
}

// swiftlint:enable nesting
