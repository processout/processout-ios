//
//  PassKitPaymentAuthorizationCoordinator.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.12.2023.
//

import PassKit
import ProcessOut

final class PassKitPaymentAuthorizationCoordinator: NSObject, PKPaymentAuthorizationControllerDelegate {

    init(
        controller: POPassKitPaymentAuthorizationController,
        paymentRequest: PKPaymentRequest,
        contactMapper: PassKitContactMapper,
        errorMapper: PassKitPaymentErrorMapper,
        cardsService: POCardsService
    ) {
        self.controller = controller
        self.contactMapper = contactMapper
        self.errorMapper = errorMapper
        self.cardsService = cardsService
        self.recentRequestUpdate = .init(request: paymentRequest)
    }

    weak var delegate: POPassKitPaymentAuthorizationControllerDelegate?

    // MARK: - PKPaymentAuthorizationControllerDelegate

    func paymentAuthorizationControllerDidFinish(_: PKPaymentAuthorizationController) {
        delegate?.paymentAuthorizationControllerDidFinish(controller)
    }

    func paymentAuthorizationController(
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
                controller, didFailToTokenizePayment: payment, error: error
            ) {
                return result
            }
            let errors = errorMapper.map(poError: error)
            return PKPaymentAuthorizationResult(status: .failure, errors: errors)
        }
        let result = await delegate?.paymentAuthorizationController(
            controller, didTokenizePayment: payment, card: card
        )
        return result ?? PKPaymentAuthorizationResult(status: .success, errors: nil)
    }

    func paymentAuthorizationControllerWillAuthorizePayment(_: PKPaymentAuthorizationController) {
        delegate?.paymentAuthorizationControllerWillAuthorizePayment(controller)
    }

    @available(iOS 14.0, *)
    func paymentAuthorizationControllerDidRequestMerchantSessionUpdate(
        controller _: PKPaymentAuthorizationController
    ) async -> PKPaymentRequestMerchantSessionUpdate {
        let result = await delegate?.paymentAuthorizationControllerDidRequestMerchantSessionUpdate(
            controller: controller
        )
        return result ?? .init(status: .success, merchantSession: nil)
    }

    @available(iOS 15.0, *)
    func paymentAuthorizationController(
        _: PKPaymentAuthorizationController, didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate {
        if let update = await delegate?.paymentAuthorizationController(controller, didChangeCouponCode: couponCode) {
            recentRequestUpdate.update(with: update)
            return update
        }
        return PKPaymentRequestCouponCodeUpdate(
            errors: [],
            paymentSummaryItems: recentRequestUpdate.paymentSummaryItems,
            shippingMethods: recentRequestUpdate.shippingMethods
        )
    }

    func paymentAuthorizationController(
        _: PKPaymentAuthorizationController, didSelectShippingMethod shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate {
        // swiftlint:disable:next line_length
        if let update = await delegate?.paymentAuthorizationController(controller, didSelectShippingMethod: shippingMethod) {
            recentRequestUpdate.update(with: update)
            return update
        }
        return PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: recentRequestUpdate.paymentSummaryItems)
    }

    func paymentAuthorizationController(
        _: PKPaymentAuthorizationController, didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate {
        if let update = await delegate?.paymentAuthorizationController(controller, didSelectShippingContact: contact) {
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

    func paymentAuthorizationController(
        _: PKPaymentAuthorizationController, didSelectPaymentMethod paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate {
        // swiftlint:disable:next line_length
        if let update = await delegate?.paymentAuthorizationController(controller, didSelectPaymentMethod: paymentMethod) {
            recentRequestUpdate.update(with: update)
            return update
        }
        return .init(errors: [], paymentSummaryItems: recentRequestUpdate.paymentSummaryItems)
    }

    func presentationWindow(for _: PKPaymentAuthorizationController) -> UIWindow? {
        delegate?.presentationWindow(for: controller)
    }

    // MARK: - Private Properties

    private unowned let controller: POPassKitPaymentAuthorizationController

    private let contactMapper: PassKitContactMapper
    private let errorMapper: PassKitPaymentErrorMapper
    private let cardsService: POCardsService

    private var recentRequestUpdate: PassKitPaymentRequestUpdate
}
