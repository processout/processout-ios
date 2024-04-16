//
//  DynamicCheckoutPassKitPaymentInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 25.03.2024.
//

import PassKit

protocol DynamicCheckoutPassKitPaymentInteractor {

    /// Boolean value indicating whether PassKit payments are supported.
    var isSupported: Bool { get }

    /// Starts payment.
    func start(request: PKPaymentRequest) async throws
}
