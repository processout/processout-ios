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

    func authorize<T>(
        request: PKPaymentRequest,
        didAuthorizePayment: @escaping (PKPayment) async throws -> T,
        delegate: POApplePayAuthorizationSessionDelegate? = nil
    ) async throws -> T {
        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        let coordinator = AuthorizationSessionCoordinator(
            didAuthorizePayment: didAuthorizePayment, delegate: delegate
        )
        controller.delegate = coordinator
        guard await controller.present() else {
            throw POFailure(message: "Unable to present authorization controller.", code: .generic(.mobile))
        }
        await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                coordinator.setContinuation(continuation: continuation)
            }
        } onCancel: {
            controller.dismiss()
        }
        await controller.dismiss()
        guard let processedPayment = coordinator.processedPayment else {
            throw POFailure(message: "Authorization was cancelled.", code: .cancelled)
        }
        return processedPayment
    }
}

@MainActor
private final class AuthorizationSessionCoordinator<ProcessedPayment>
    : NSObject, PKPaymentAuthorizationControllerDelegate {

    init(
        didAuthorizePayment: @escaping (PKPayment) async throws -> ProcessedPayment,
        delegate: POApplePayAuthorizationSessionDelegate?
    ) {
        self.delegate = delegate
        self.didAuthorizePayment = didAuthorizePayment
        didFinish = false
        super.init()
    }

    /// Payment information if any.
    var payment: PKPayment?

    /// Processed payment information if any.
    var processedPayment: ProcessedPayment?

    func setContinuation(continuation: CheckedContinuation<Void, Never>) {
        if didFinish {
            continuation.resume()
        } else {
            self.continuation = continuation
        }
    }

    // MARK: - PKPaymentAuthorizationControllerDelegate

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        didFinish = true
        continuation?.resume()
        continuation = nil
    }

    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment
    ) async -> PKPaymentAuthorizationResult {
        do {
            let processedPayment = try await didAuthorizePayment(payment)
            // swiftlint:disable:next line_length
            let result = await delegate?.applePayAuthorizationSession(didAuthorizePayment: payment) ?? .init(status: .success, errors: nil)
            if case .success = result.status {
                self.processedPayment = processedPayment
            }
            return result
        } catch {
            // todo(andrii-vysotskyi): map error
            return .init(status: .failure, errors: nil)
        }
    }

    @MainActor
    func paymentAuthorizationControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationController) {
        // todo(andrii-vysotskyi): forward to delegate
    }

    @available(iOS 14.0, *)
    func paymentAuthorizationControllerDidRequestMerchantSessionUpdate(
        controller: PKPaymentAuthorizationController
    ) async -> PKPaymentRequestMerchantSessionUpdate {
        .init() // todo(andrii-vysotskyi): forward to delegate
    }

    @available(iOS 15.0, *)
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate {
        .init() // todo(andrii-vysotskyi): forward to delegate
    }

    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectShippingMethod shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate {
        .init() // todo(andrii-vysotskyi): forward to delegate
    }

    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate {
        .init() // todo(andrii-vysotskyi): forward to delegate
    }

    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectPaymentMethod paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate {
        .init() // todo(andrii-vysotskyi): forward to delegate
    }

    @available(iOS 14.0, *)
    nonisolated func presentationWindow(for controller: PKPaymentAuthorizationController) -> UIWindow? {
        nil
    }

    // MARK: - Private Properties

    private let delegate: POApplePayAuthorizationSessionDelegate?
    private let didAuthorizePayment: (PKPayment) async throws -> ProcessedPayment

    private var continuation: CheckedContinuation<Void, Never>?
    private var didFinish: Bool
}
