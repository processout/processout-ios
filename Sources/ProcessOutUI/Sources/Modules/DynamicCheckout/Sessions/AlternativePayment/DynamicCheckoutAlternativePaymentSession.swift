//
//  DynamicCheckoutAlternativePaymentSession.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.03.2024.
//

import Foundation
import ProcessOut

@MainActor
protocol DynamicCheckoutAlternativePaymentSession {

    /// Starts alternative payment.
    func start(url: URL) async throws -> POAlternativePaymentMethodResponse
}
