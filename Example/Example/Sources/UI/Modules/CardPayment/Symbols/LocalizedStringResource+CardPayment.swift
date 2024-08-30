//
//  LocalizedStringResource+CardPayment.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.08.2024.
//

import Foundation

extension LocalizedStringResource {

    enum CardPayment {

        /// Title.
        static let title = LocalizedStringResource("card-payment.title")

        /// 3DS service.
        static let threeDSService = LocalizedStringResource("card-payment.3ds-service")

        /// Continue button.
        static let pay = LocalizedStringResource("card-payment.pay")

        /// Success message.
        static let successMessage = LocalizedStringResource("card-payment.success-message-\(placeholder: .object)")
    }
}
