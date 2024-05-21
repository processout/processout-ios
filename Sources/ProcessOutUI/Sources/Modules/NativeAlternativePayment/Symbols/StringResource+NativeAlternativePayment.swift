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

            /// Cancel button title.
            static let cancel = POStringResource("native-alternative-payment.cancel-button.title", comment: "")
        }

        enum Success {

            /// Success message.
            static let message = POStringResource("native-alternative-payment.success.message", comment: "")
        }

        enum CancelConfirmation {

            /// Success message.
            static let title = POStringResource("native-alternative-payment.cancel-confirmation.title", comment: "")

            /// Confirm button title..
            static let confirm = POStringResource("native-alternative-payment.cancel-confirmation.confirm", comment: "")

            /// Cancel button title.
            static let cancel = POStringResource("native-alternative-payment.cancel-confirmation.cancel", comment: "")
        }
    }
}

// swiftlint:enable nesting
