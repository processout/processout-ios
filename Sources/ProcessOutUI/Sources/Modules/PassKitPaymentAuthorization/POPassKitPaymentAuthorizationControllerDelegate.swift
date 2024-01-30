//
//  POPassKitPaymentAuthorizationControllerDelegate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.12.2023.
//

import PassKit
import ProcessOut

/// Methods that let you respond to user interactions with payment authorization controller.
public protocol POPassKitPaymentAuthorizationControllerDelegate: AnyObject {

    /// Sent to the delegate when payment authorization is finished.  This may occur when
    /// the user cancels the request, or after the PKPaymentAuthorizationStatus parameter of the
    /// paymentAuthorizationController:didAuthorizePayment:completion: has been shown to the user.
    ///
    /// The delegate is responsible for dismissing and releasing the controller in this method.
    @MainActor
    func paymentAuthorizationControllerDidFinish(_ controller: POPassKitPaymentAuthorizationController)

    /// Sent to the delegate after the user has acted on the payment request and it was tokenized by ProcessOut.
    @MainActor
    func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didTokenizePayment payment: PKPayment,
        card: POCard
    ) async -> PKPaymentAuthorizationResult

    /// Sent to the delegate when payment tokenization fails. Your implementation can convert given error
    /// to `PKPaymentError` and return appropriate result or `nil` if to perform it automatically.
    @MainActor
    func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didFailToTokenizePayment payment: PKPayment,
        error: Error
    ) async -> PKPaymentAuthorizationResult?

    /// Sent to the delegate before the payment is authorized, but after the user has authenticated using
    /// the side button.
    @MainActor
    func paymentAuthorizationControllerWillAuthorizePayment(_ controller: POPassKitPaymentAuthorizationController)

    /// Requests an object that validates the identity of a merchant for a payment request.
    @available(iOS 14.0, *)
    @MainActor
    func paymentAuthorizationControllerDidRequestMerchantSessionUpdate(
        controller: POPassKitPaymentAuthorizationController
    ) async -> PKPaymentRequestMerchantSessionUpdate?

    /// Tells the delegate that the user entered or updated a coupon code.
    @available(iOS 15.0, *)
    @MainActor
    func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate?

    /// Sent when the user has selected a new shipping method.  The delegate should determine
    /// shipping costs based on the shipping method and either the shipping address contact in the original
    /// PKPaymentRequest or the contact provided by the last call to paymentAuthorizationController:
    /// didSelectShippingContact:completion:.
    @MainActor
    func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didSelectShippingMethod shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate?

    /// Tells the delegate that the user selected a shipping address.
    @MainActor
    func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate?

    /// Sent when the user has selected a new payment card.  Use this delegate callback if you need to
    /// update the summary items in response to the card type changing (for example, applying credit card surcharges)
    @MainActor
    func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didSelectPaymentMethod paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate?

    /// Returns the window in which to present a payment authorization sheet.
    func presentationWindow(for controller: POPassKitPaymentAuthorizationController) -> UIWindow?
}

extension POPassKitPaymentAuthorizationControllerDelegate {

    public func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didFailToTokenizePayment payment: PKPayment,
        error: Error
    ) async -> PKPaymentAuthorizationResult? {
        nil
    }

    public func paymentAuthorizationControllerWillAuthorizePayment(
        _ controller: POPassKitPaymentAuthorizationController
    ) {
        // Ignored
    }

    @available(iOS 14.0, *)
    public func paymentAuthorizationControllerDidRequestMerchantSessionUpdate(
        controller: POPassKitPaymentAuthorizationController
    ) async -> PKPaymentRequestMerchantSessionUpdate? {
        nil
    }

    @available(iOS 15.0, *)
    public func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate? {
        nil
    }

    public func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didSelectShippingMethod shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate? {
        nil
    }

    public func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate? {
        nil
    }

    public func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didSelectPaymentMethod paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate? {
        nil
    }

    public func presentationWindow(for controller: POPassKitPaymentAuthorizationController) -> UIWindow? {
        nil
    }
}
