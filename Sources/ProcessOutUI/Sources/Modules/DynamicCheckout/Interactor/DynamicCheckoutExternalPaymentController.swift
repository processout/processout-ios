//
//  DynamicCheckoutPaymentController.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 20.03.2024.
//

protocol DynamicCheckoutExternalPaymentController<Source> {

    associatedtype Source

    /// Boolean value indicating whether payment can be started.
    var canStart: Bool { get async }

    /// Starts payment.
    func start(source: Source) async throws
}

extension DynamicCheckoutExternalPaymentController where Source == Void {

    func start() async throws {
        try await start(source: ())
    }
}
