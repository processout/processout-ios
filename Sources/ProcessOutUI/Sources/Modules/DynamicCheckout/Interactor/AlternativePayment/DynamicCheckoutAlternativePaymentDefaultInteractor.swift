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

    func start(url: URL) async throws {
        guard let returnUrl = configuration.returnUrl else {
            throw POFailure(message: "Return URL must be set.", code: .generic(.mobile))
        }
        // swiftlint:disable:next implicitly_unwrapped_optional
        var controller: POAlternativePaymentMethodController!
        // todo(andrii-vysotskyi): set tint colors and configuration
        _ = try await withCheckedThrowingContinuation { continuation in
            controller = .init(url: url, returnUrl: returnUrl, completion: continuation.resume(with:))
        }
        _ = await controller.present()
    }

    // MARK: - Private Properties

    private let configuration: PODynamicCheckoutAlternativePaymentConfiguration
}
