//
//  ApplePayAuthorizationSessionDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.09.2024.
//

import Foundation
import PassKit

protocol POApplePayAuthorizationSessionDelegate: AnyObject {

    /// Sent to the delegate after the user has acted on the payment request and it was tokenized by ProcessOut.
    @MainActor
    func applePayAuthorizationSession(didAuthorizePayment payment: PKPayment) async -> PKPaymentAuthorizationResult
}
