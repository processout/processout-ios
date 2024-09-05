//
//  ApplePayAuthorizationSessionCoordinator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.09.2024.
//

import PassKit

@MainActor
final class ApplePayAuthorizationSessionCoordinator: NSObject, PKPaymentAuthorizationControllerDelegate {

    init(delegate: ApplePayAuthorizationSessionDelegate?) {
        self.delegate = delegate
        didFinish = false
        super.init()
    }

    /// Payment information.
    var payment: PKPayment?

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
        let result = await delegate?.applePayAuthorizationSession(didAuthorizePayment: payment)
        switch result?.status {
        case nil, .success:
            self.payment = payment
        default:
            break
        }
        return result ?? .init(status: .success, errors: nil)
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

    private let delegate: ApplePayAuthorizationSessionDelegate?

    private var continuation: CheckedContinuation<Void, Never>?
    private var didFinish: Bool
}
