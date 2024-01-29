//
//  POPassKitPaymentAuthorizationController.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.12.2023.
//

import PassKit
@_spi(PO) import ProcessOut

public final class POPassKitPaymentAuthorizationController
    : NSObject, PKPaymentAuthorizationControllerDelegate {

    /// Determine whether this device can process payment requests.
    public class func canMakePayments() -> Bool {
        PKPaymentAuthorizationController.canMakePayments()
    }

    /// Determine whether this device can process payment requests using specific payment network brands.
    public class func canMakePayments(usingNetworks supportedNetworks: [PKPaymentNetwork]) -> Bool {
        PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks)
    }

    /// Determine whether this device can process payments using the specified networks and capabilities bitmask
    public class func canMakePayments(
        usingNetworks supportedNetworks: [PKPaymentNetwork], capabilities capabilties: PKMerchantCapability
    ) -> Bool {
        PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks, capabilities: capabilties)
    }

    /// Initialize the controller with a payment request.
    public init?(paymentRequest: PKPaymentRequest) {
        if PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) == nil {
            return nil
        }
        self.paymentRequest = paymentRequest
        controller = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        contactMapper = DefaultPassKitContactMapper(logger: ProcessOut.shared.logger)
        errorMapper = DefaultPassKitPaymentErrorMapper(logger: ProcessOut.shared.logger)
        cardsService = ProcessOut.shared.cards
        super.init()
        commonInit()
    }

    /// Presents the Apple Pay UI modally over your app. You are responsible for dismissal
    public func present(completion: ((Bool) -> Void)? = nil) {
        controller.present(completion: completion)
    }

    /// Dismisses the Apple Pay UI. Call this when you receive the paymentAuthorizationControllerDidFinish delegate
    /// callback, or otherwise wish a dismissal to occur
    public func dismiss(completion: (() -> Void)? = nil) {
        controller.dismiss(completion: completion)
    }

    /// The controller's delegate.
    public weak var delegate: POPassKitPaymentAuthorizationControllerDelegate?

    // MARK: - PKPaymentAuthorizationControllerDelegate

    public func paymentAuthorizationControllerDidFinish(_: PKPaymentAuthorizationController) {
        delegate?.paymentAuthorizationControllerDidFinish(self)
    }

    public func paymentAuthorizationController(
        _: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment
    ) async -> PKPaymentAuthorizationResult {
        let request = POApplePayCardTokenizationRequest(
            payment: payment,
            contact: payment.billingContact.flatMap(contactMapper.map),
            metadata: nil // todo(andrii-vysotskyi): decide if metadata injection should be allowed
        )
        let card: POCard
        do {
            card = try await cardsService.tokenize(request: request)
        } catch {
            if let result = await delegate?.paymentAuthorizationController(
                self, didFailToTokenizePayment: payment, error: error
            ) {
                return result
            }
            let errors = errorMapper.map(poError: error)
            return PKPaymentAuthorizationResult(status: .failure, errors: errors)
        }
        let result = await delegate?.paymentAuthorizationController(self, didTokenizePayment: payment, card: card)
        return result ?? PKPaymentAuthorizationResult(status: .success, errors: nil)
    }

    public func paymentAuthorizationControllerWillAuthorizePayment(_: PKPaymentAuthorizationController) {
        delegate?.paymentAuthorizationControllerWillAuthorizePayment(self)
    }

    @available(iOS 14.0, *)
    public func paymentAuthorizationControllerDidRequestMerchantSessionUpdate(
        controller _: PKPaymentAuthorizationController
    ) async -> PKPaymentRequestMerchantSessionUpdate {
        let result = await delegate?.paymentAuthorizationControllerDidRequestMerchantSessionUpdate(controller: self)
        return result ?? .init(status: .failure, merchantSession: nil)
    }

    @available(iOS 15.0, *)
    public func paymentAuthorizationController(
        _: PKPaymentAuthorizationController, didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate {
        let update = await delegate?.paymentAuthorizationController(self, didChangeCouponCode: couponCode)
        return update ?? PKPaymentRequestCouponCodeUpdate()
    }

    public func paymentAuthorizationController(
        _: PKPaymentAuthorizationController, didSelectShippingMethod shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate {
        let update = await delegate?.paymentAuthorizationController(self, didSelectShippingMethod: shippingMethod)
        return update ?? PKPaymentRequestShippingMethodUpdate()
    }

    public func paymentAuthorizationController(
        _: PKPaymentAuthorizationController, didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate {
        let update = await delegate?.paymentAuthorizationController(self, didSelectShippingContact: contact)
        return update ?? PKPaymentRequestShippingContactUpdate()
    }

    public func paymentAuthorizationController(
        _: PKPaymentAuthorizationController, didSelectPaymentMethod paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate {
        let update = await delegate?.paymentAuthorizationController(self, didSelectPaymentMethod: paymentMethod)
        return update ?? PKPaymentRequestPaymentMethodUpdate()
    }

    public func presentationWindow(for _: PKPaymentAuthorizationController) -> UIWindow? {
        delegate?.presentationWindow(for: self)
    }

    // MARK: - Private Nested Types

    private enum AssociatedObjectKeys {
        static var controller: UInt8 = 0
    }

    // MARK: - Private Properties

    private let paymentRequest: PKPaymentRequest
    private let controller: PKPaymentAuthorizationController

    private let contactMapper: PassKitContactMapper
    private let errorMapper: PassKitPaymentErrorMapper
    private let cardsService: POCardsService

    // MARK: - Private Methods

    private func commonInit() {
        controller.delegate = self
        // Bound lifecycle of self to PKPaymentAuthorizationController.
        objc_setAssociatedObject(controller, &AssociatedObjectKeys.controller, self, .OBJC_ASSOCIATION_RETAIN)
    }
}

extension POPassKitPaymentAuthorizationController {

    /// Presents the payment sheet modally over your app.
    public func present() async -> Bool {
        await withUnsafeContinuation { continuation in
            present(completion: continuation.resume)
        }
    }

    /// Dismisses the payment sheet.
    public func dismiss() async {
        await withUnsafeContinuation { continuation in
            dismiss(completion: continuation.resume)
        }
    }
}
