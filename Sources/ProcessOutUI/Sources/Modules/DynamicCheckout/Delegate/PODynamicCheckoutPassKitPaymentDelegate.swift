//
//  PODynamicCheckoutPassKitPaymentDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 20.03.2024.
//

import PassKit

@MainActor
protocol PODynamicCheckoutPassKitPaymentDelegate: AnyObject {

    /// Requests an object that validates the identity of a merchant for a payment request.
    @available(iOS 14.0, *)
    func dynamicCheckoutPassKitPaymentDidRequestMerchantSessionUpdate() async -> PKPaymentRequestMerchantSessionUpdate?

    /// Tells the delegate that the user entered or updated a coupon code.
    @available(iOS 15.0, *)
    func dynamicCheckoutPassKitPayment(
        didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate?

    /// Sent when the user has selected a new shipping method.  The delegate should determine
    /// shipping costs based on the shipping method and either the shipping address contact in the original
    /// PKPaymentRequest or the contact provided by the last call to paymentAuthorizationController:
    /// didSelectShippingContact:completion:.
    func dynamicCheckoutPassKitPayment(
        didSelectShippingMethod shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate?

    /// Tells the delegate that the user selected a shipping address.
    func dynamicCheckoutPassKitPayment(
        didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate?

    /// Sent when the user has selected a new payment card.  Use this delegate callback if you need to
    /// update the summary items in response to the card type changing (for example, applying credit card surcharges)
    func dynamicCheckoutPassKitPayment(
        didSelectPaymentMethod paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate?
}
