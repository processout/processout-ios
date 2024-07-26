//
//  DynamicCheckoutPassKitPaymentSession.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 25.03.2024.
//

import PassKit

@MainActor
protocol DynamicCheckoutPassKitPaymentSession {

    /// Boolean value indicating whether PassKit payments are supported.
    var isSupported: Bool { get }

    /// Starts payment.
    func start(invoiceId: String, request: PKPaymentRequest) async throws
}
