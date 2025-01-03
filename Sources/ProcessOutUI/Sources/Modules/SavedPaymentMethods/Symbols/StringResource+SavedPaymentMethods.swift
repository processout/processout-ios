//
//  StringResource+SavedPaymentMethods.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.01.2025.
//

@_spi(PO) import ProcessOut

extension POStringResource {

    enum SavedPaymentMethods {

        /// Screen title.
        static let title = POStringResource("saved-payment-methods.title", comment: "")

        /// Generic error.
        static let genericError = POStringResource("saved-payment-methods.generic-error", comment: "")
    }
}
