//
//  DynamicCheckoutAlternativePaymentInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.03.2024.
//

import Foundation
import ProcessOut

protocol DynamicCheckoutAlternativePaymentInteractor {

    /// Starts alternative payment.
    func start(url: URL) async throws -> POAlternativePaymentMethodResponse
}
