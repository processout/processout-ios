//
//  ApplePayAuthorizationSessionDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.09.2024.
//

import PassKit

protocol ApplePayAuthorizationSessionDelegate: AnyObject, Sendable {

    /// Sent to the delegate after the user has acted on the payment request.
    @MainActor
    func applePayAuthorizationSession(didAuthorizePayment payment: PKPayment) async -> PKPaymentAuthorizationResult

    /// Sent to the delegate before the payment is authorized, but
    /// after the user has authenticated using the side button.
    @MainActor
    func applePayAuthorizationSessionWillAuthorizePayment()

    /// Requests an object that validates the identity of a merchant for a payment request.
    @MainActor
    func applePayAuthorizationSessionDidRequestMerchantSessionUpdate() async -> PKPaymentRequestMerchantSessionUpdate?

    /// Tells the delegate that the user entered or updated a coupon code.
    @available(iOS 15, *)
    @MainActor
    func applePayAuthorizationSession(
        didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate?

    /// Sent when the user has selected a new shipping method.
    @MainActor
    func applePayAuthorizationSession(
        didSelectShippingMethod shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate?

    /// Tells the delegate that the user selected a shipping address.
    @MainActor
    func applePayAuthorizationSession(
        didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate?

    /// Sent when the user has selected a new payment card.
    @MainActor
    func applePayAuthorizationSession(
        didSelectPaymentMethod paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate?
}
