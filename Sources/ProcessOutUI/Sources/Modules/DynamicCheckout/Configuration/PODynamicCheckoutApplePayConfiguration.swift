//
//  PODynamicCheckoutApplePayConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 04.03.2024.
//

import PassKit

public struct PODynamicCheckoutApplePayConfiguration {

    /// Payment request.
    public let paymentRequest: PKPaymentRequest

    /// Creates apple
    public init(paymentRequest: PKPaymentRequest) {
        self.paymentRequest = paymentRequest
    }
}
