//
//  POApplePayTokenizationDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.09.2024.
//

import PassKit

public protocol POApplePayTokenizationDelegate: AnyObject {

    /// Sent to the delegate after the user has acted on the payment request and it was tokenized by ProcessOut.
    func applePayTokenization(
        didTokenizePayment payment: PKPayment, card: POCard
    ) async -> PKPaymentAuthorizationResult
}
