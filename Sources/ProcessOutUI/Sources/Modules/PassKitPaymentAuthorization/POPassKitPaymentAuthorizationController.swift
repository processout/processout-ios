//
//  POPassKitPaymentAuthorizationController.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.12.2023.
//

import PassKit
@_spi(PO) import ProcessOut

@_spi(PO) public final class POPassKitPaymentAuthorizationController
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
        recentRequestUpdate = .init(request: paymentRequest)
        super.init()
        controller.delegate = self
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
        return result ?? .init(status: .success, merchantSession: nil)
    }

    @available(iOS 15.0, *)
    public func paymentAuthorizationController(
        _: PKPaymentAuthorizationController, didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate {
        if let update = await delegate?.paymentAuthorizationController(self, didChangeCouponCode: couponCode) {
            recentRequestUpdate.update(with: update)
            return update
        }
        return PKPaymentRequestCouponCodeUpdate(
            errors: [],
            paymentSummaryItems: recentRequestUpdate.paymentSummaryItems,
            shippingMethods: recentRequestUpdate.shippingMethods
        )
    }

    public func paymentAuthorizationController(
        _: PKPaymentAuthorizationController, didSelectShippingMethod shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate {
        if let update = await delegate?.paymentAuthorizationController(self, didSelectShippingMethod: shippingMethod) {
            recentRequestUpdate.update(with: update)
            return update
        }
        return PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: recentRequestUpdate.paymentSummaryItems)
    }

    public func paymentAuthorizationController(
        _: PKPaymentAuthorizationController, didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate {
        if let update = await delegate?.paymentAuthorizationController(self, didSelectShippingContact: contact) {
            recentRequestUpdate.update(with: update)
            recentRequestUpdate.shippingMethods = update.shippingMethods
            return update
        }
        return PKPaymentRequestShippingContactUpdate(
            errors: [],
            paymentSummaryItems: recentRequestUpdate.paymentSummaryItems,
            shippingMethods: recentRequestUpdate.shippingMethods
        )
    }

    public func paymentAuthorizationController(
        _: PKPaymentAuthorizationController, didSelectPaymentMethod paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate {
        if let update = await delegate?.paymentAuthorizationController(self, didSelectPaymentMethod: paymentMethod) {
            recentRequestUpdate.update(with: update)
            return update
        }
        return .init(errors: [], paymentSummaryItems: recentRequestUpdate.paymentSummaryItems)
    }

    public func presentationWindow(for _: PKPaymentAuthorizationController) -> UIWindow? {
        delegate?.presentationWindow(for: self)
    }

    // MARK: - Private Properties

    private let paymentRequest: PKPaymentRequest
    private let controller: PKPaymentAuthorizationController

    private let contactMapper: PassKitContactMapper
    private let errorMapper: PassKitPaymentErrorMapper
    private let cardsService: POCardsService

    private var recentRequestUpdate: PassKitPaymentRequestUpdate
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
