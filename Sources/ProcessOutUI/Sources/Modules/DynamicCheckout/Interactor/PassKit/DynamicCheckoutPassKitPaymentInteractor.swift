//
//  DynamicCheckoutPassKitPaymentInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 25.03.2024.
//

import Foundation

protocol DynamicCheckoutPassKitPaymentInteractor {

    /// Boolean value indicating whether payment can be started.
    var canStart: Bool { get }

    /// Starts payment.
    func start() async throws
}
