//
//  ApplePayAuthorizationSessionDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.09.2024.
//

import Foundation
import PassKit

protocol ApplePayAuthorizationSessionDelegate: AnyObject {

    /// Sent to the delegate after the user has acted on the payment request.
    @MainActor
    func applePayAuthorizationSession(didAuthorizePayment payment: PKPayment) async -> PKPaymentAuthorizationResult
}
