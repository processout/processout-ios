//
//  ApplePayAuthorizationSessionCoordinator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.09.2024.
//

import PassKit

@MainActor
final class ApplePayAuthorizationSessionCoordinator: NSObject, PKPaymentAuthorizationControllerDelegate {

    nonisolated init(delegate: ApplePayAuthorizationSessionDelegate?) {
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

    func paymentAuthorizationControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationController) {
        delegate?.applePayAuthorizationSessionWillAuthorizePayment()
    }

    @available(iOS 14.0, *)
    func paymentAuthorizationControllerDidRequestMerchantSessionUpdate(
        controller: PKPaymentAuthorizationController
    ) async -> PKPaymentRequestMerchantSessionUpdate {
        let update = await delegate?.applePayAuthorizationSessionDidRequestMerchantSessionUpdate()
        return update ?? .init(status: .success, merchantSession: nil)
    }

    @available(iOS 15.0, *)
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate {
        await delegate?.applePayAuthorizationSession(didChangeCouponCode: couponCode) ?? .init()
    }

    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectShippingMethod shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate {
        await delegate?.applePayAuthorizationSession(didSelectShippingMethod: shippingMethod) ?? .init()
    }

    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate {
        await delegate?.applePayAuthorizationSession(didSelectShippingContact: contact) ?? .init()
    }

    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didSelectPaymentMethod paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate {
        await delegate?.applePayAuthorizationSession(didSelectPaymentMethod: paymentMethod) ?? .init()
    }

    // MARK: - Private Properties

    private let delegate: ApplePayAuthorizationSessionDelegate?
    private var continuation: CheckedContinuation<Void, Never>?
    private var didFinish: Bool
}
