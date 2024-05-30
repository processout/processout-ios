//
//  DynamicCheckoutAlternativePaymentDefaultInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 25.03.2024.
//

import Foundation
import ProcessOut

@MainActor
final class DynamicCheckoutAlternativePaymentDefaultInteractor: DynamicCheckoutAlternativePaymentInteractor {

    init(configuration: PODynamicCheckoutAlternativePaymentConfiguration) {
        self.configuration = configuration
    }

    func start(url: URL) async throws -> POAlternativePaymentMethodResponse {
        guard let returnUrl = configuration.returnUrl else {
            throw POFailure(message: "Return URL must be set.", code: .generic(.mobile))
        }
        // swiftlint:disable:next implicitly_unwrapped_optional
        var continuation: UnsafeContinuation<POAlternativePaymentMethodResponse, Error>!
        let session = POWebAuthenticationSession(alternativePaymentMethodUrl: url, returnUrl: returnUrl) { result in
            continuation.resume(with: result)
        }
        guard await session.start() else {
            throw POFailure(message: "Unable to start alternative payment.", code: .generic(.mobile))
        }
        return try await withUnsafeThrowingContinuation { continuation = $0 }
    }

    // MARK: - Private Properties

    private let configuration: PODynamicCheckoutAlternativePaymentConfiguration
}
