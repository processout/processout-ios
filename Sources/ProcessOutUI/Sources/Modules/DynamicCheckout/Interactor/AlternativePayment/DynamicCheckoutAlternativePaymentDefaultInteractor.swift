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
        // todo(andrii-vysotskyi): set tint colors and configuration
        let controller = POAlternativePaymentMethodController(url: url, returnUrl: returnUrl) { result in
            continuation.resume(with: result)
        }
        _ = await controller.present() // todo(andrii-vysotskyi): handle case when present completes early
        return try await withUnsafeThrowingContinuation { unsafeContinuation in
            continuation = unsafeContinuation
        }
    }

    // MARK: - Private Properties

    private let configuration: PODynamicCheckoutAlternativePaymentConfiguration
}
