//
//  DynamicCheckoutAlternativePaymentController.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.03.2024.
//

import Foundation

@MainActor
final class DynamicCheckoutAlternativePaymentController: DynamicCheckoutExternalPaymentController {

    var canStart: Bool {
        get async {
            true
        }
    }

    func start(source: DynamicCheckoutAlternativePaymentControllerSource) async throws {
        // swiftlint:disable:next implicitly_unwrapped_optional
        var controller: POAlternativePaymentMethodController!
        // todo(andrii-vysotskyi): set tint colors and configuration
        _ = try await withCheckedThrowingContinuation { continuation in
            controller = .init(url: source.url, returnUrl: source.returnUrl, completion: continuation.resume(with:))
        }
        _ = await controller.present()
    }
}
