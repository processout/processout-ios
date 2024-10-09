//
//  DefaultApplePayAuthorizationSession.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.09.2024.
//

import PassKit

@MainActor
final class DefaultApplePayAuthorizationSession: ApplePayAuthorizationSession {

    nonisolated init() {
        // Ignored
    }

    // MARK: - ApplePayAuthorizationSession

    func authorize(
        request: PKPaymentRequest,
        delegate: ApplePayAuthorizationSessionDelegate?
    ) async throws -> PKPayment {
        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        let coordinator = ApplePayAuthorizationSessionCoordinator(delegate: delegate)
        controller.delegate = coordinator
        guard await controller.present() else {
            throw POFailure(message: "Unable to present payment authorization controller.", code: .generic(.mobile))
        }
        await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                coordinator.setContinuation(continuation: continuation)
            }
        } onCancel: {
            controller.dismiss()
        }
        await controller.dismiss()
        guard let payment = coordinator.payment else {
            throw POFailure(message: "Payment authorization was cancelled.", code: .cancelled)
        }
        return payment
    }
}
