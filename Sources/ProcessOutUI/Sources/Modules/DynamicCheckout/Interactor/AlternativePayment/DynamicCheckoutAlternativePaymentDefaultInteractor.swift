//
//  DynamicCheckoutAlternativePaymentDefaultInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 25.03.2024.
//

import Foundation

@MainActor
final class DynamicCheckoutAlternativePaymentDefaultInteractor: DynamicCheckoutAlternativePaymentInteractor {

    init(returnUrl: URL) {
        self.returnUrl = returnUrl
    }

    func start(url: URL) async throws {
        // swiftlint:disable:next implicitly_unwrapped_optional
        var controller: POAlternativePaymentMethodController!
        // todo(andrii-vysotskyi): set tint colors and configuration
        _ = try await withCheckedThrowingContinuation { continuation in
            controller = .init(url: url, returnUrl: returnUrl, completion: continuation.resume(with:))
        }
        _ = await controller.present()
    }

    // MARK: - Private Properties

    private let returnUrl: URL
}
