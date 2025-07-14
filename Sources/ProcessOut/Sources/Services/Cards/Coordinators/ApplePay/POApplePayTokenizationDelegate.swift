//
//  POApplePayTokenizationDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.09.2024.
//

import PassKit

@preconcurrency
public protocol POApplePayTokenizationDelegate: Sendable { // swiftlint:disable:this class_delegate_protocol

    /// Sent to the delegate after the user has acted on the payment request and it was tokenized by ProcessOut.
    @MainActor
    func applePayTokenization(
        didAuthorizePayment payment: PKPayment, card: POCard
    ) async -> PKPaymentAuthorizationResult

    /// Sent to the delegate before the payment is authorized, but
    /// after the user has authenticated using the side button.
    @MainActor
    func applePayTokenizationWillAuthorizePayment()

    /// Requests an object that validates the identity of a merchant for a payment request.
    @MainActor
    func applePayTokenizationDidRequestMerchantSessionUpdate() async -> PKPaymentRequestMerchantSessionUpdate?

    /// Tells the delegate that the user entered or updated a coupon code.
    @available(iOS 15, *)
    @MainActor
    func applePayTokenization(didChangeCouponCode couponCode: String) async -> PKPaymentRequestCouponCodeUpdate?

    /// Sent when the user has selected a new shipping method. The delegate should determine
    /// shipping costs based on the shipping method and either the shipping address contact in the original
    /// PKPaymentRequest or the contact provided by the last call to
    /// ``applePayTokenization(didSelectShippingMethod:)``.
    @MainActor
    func applePayTokenization(
        didSelectShippingMethod shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate?

    /// Tells the delegate that the user selected a shipping address.
    @MainActor
    func applePayTokenization(
        didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate?

    /// Sent when the user has selected a new payment card. Use this delegate callback if you need to
    /// update the summary items in response to the card type changing (for example, applying credit card surcharges).
    @MainActor
    func applePayTokenization(
        didSelectPaymentMethod paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate?
}

extension POApplePayTokenizationDelegate {

    @MainActor
    public func applePayTokenization(
        didAuthorizePayment payment: PKPayment, card: POCard
    ) async -> PKPaymentAuthorizationResult {
        .init(status: .success, errors: nil)
    }

    @MainActor
    public func applePayTokenizationWillAuthorizePayment() {
        // Ignored
    }

    @MainActor
    public func applePayTokenizationDidRequestMerchantSessionUpdate() async -> PKPaymentRequestMerchantSessionUpdate? {
        nil
    }

    @available(iOS 15, *)
    @MainActor
    public func applePayTokenization(
        didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate? {
        nil
    }

    @MainActor
    public func applePayTokenization(
        didSelectShippingMethod shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate? {
        nil
    }

    @MainActor
    public func applePayTokenization(
        didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate? {
        nil
    }

    @MainActor
    public func applePayTokenization(
        didSelectPaymentMethod paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate? {
        nil
    }
}
