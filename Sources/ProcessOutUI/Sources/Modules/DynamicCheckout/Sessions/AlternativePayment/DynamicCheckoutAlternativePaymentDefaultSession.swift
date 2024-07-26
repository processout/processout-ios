//
//  DynamicCheckoutAlternativePaymentDefaultSession.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 25.03.2024.
//

import Foundation
import ProcessOut

final class DynamicCheckoutAlternativePaymentDefaultSession: DynamicCheckoutAlternativePaymentSession {

    init(configuration: PODynamicCheckoutAlternativePaymentConfiguration) {
        self.configuration = configuration
    }

    func start(url: URL) async throws -> POAlternativePaymentMethodResponse {
        guard let returnUrl = configuration.returnUrl else {
            throw POFailure(message: "Return URL must be set.", code: .generic(.mobile))
        }
        return try await withCheckedThrowingContinuation { continuation in
            let session = POWebAuthenticationSession(alternativePaymentMethodUrl: url, returnUrl: returnUrl) { result in
                continuation.resume(with: result)
            }
            Task {
                guard await !session.start() else {
                    return
                }
                let failure = POFailure(message: "Unable to start alternative payment.", code: .generic(.mobile))
                continuation.resume(throwing: failure)
            }
        }
    }

    // MARK: - Private Properties

    private let configuration: PODynamicCheckoutAlternativePaymentConfiguration
}
