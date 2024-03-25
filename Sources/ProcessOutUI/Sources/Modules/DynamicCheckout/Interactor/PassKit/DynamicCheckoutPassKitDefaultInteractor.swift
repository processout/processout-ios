//
//  DynamicCheckoutPassKitPaymentDefaultInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.03.2024.
//

import Foundation
import PassKit
import ProcessOut

@MainActor
final class DynamicCheckoutPassKitPaymentDefaultInteractor: DynamicCheckoutPassKitPaymentInteractor {

    init(
        configuration: PODynamicCheckoutConfiguration,
        delegate: PODynamicCheckoutPassKitPaymentDelegate?,
        dynamicCheckoutDelegate: PODynamicCheckoutDelegate,
        invoicesService: POInvoicesService
    ) {
        self.configuration = configuration
        self.delegate = delegate
        self.dynamicCheckoutDelegate = dynamicCheckoutDelegate
        self.invoicesService = invoicesService
        didAuthorizeInvoice = false
    }

    nonisolated var canStart: Bool {
        configuration.applePay != nil && POPassKitPaymentAuthorizationController.canMakePayments()
    }

    func start() async throws {
        guard let paymentRequest = configuration.applePay?.paymentRequest,
              let controller = POPassKitPaymentAuthorizationController(paymentRequest: paymentRequest) else {
            assertionFailure("ApplePay payment shouldn't be attempted when unavailable.")
            throw POFailure(code: .generic(.mobile))
        }
        controller.delegate = self
        _ = await controller.present()
        await withCheckedContinuation { continuation in
            self.didFinishContinuation = continuation
        }
        await controller.dismiss()
        if didAuthorizeInvoice {
            return
        }
        throw POFailure(code: .generic(.mobile))
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService
    private let configuration: PODynamicCheckoutConfiguration

    private weak var delegate: PODynamicCheckoutPassKitPaymentDelegate?
    private weak var dynamicCheckoutDelegate: PODynamicCheckoutDelegate?

    private var didFinishContinuation: CheckedContinuation<Void, Never>?
    private var didAuthorizeInvoice: Bool
}

extension DynamicCheckoutPassKitPaymentDefaultInteractor: POPassKitPaymentAuthorizationControllerDelegate {

    func paymentAuthorizationControllerDidFinish(_ controller: POPassKitPaymentAuthorizationController) {
        guard let didFinishContinuation else {
            preconditionFailure("Continue must be set.")
        }
        didFinishContinuation.resume()
    }

    func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didTokenizePayment payment: PKPayment,
        card: POCard
    ) async -> PKPaymentAuthorizationResult {
        let authorizationRequest = POInvoiceAuthorizationRequest(invoiceId: configuration.invoiceId, source: card.id)
        do {
            guard let threeDSService = dynamicCheckoutDelegate?.dynamicCheckout3DSService() else {
                throw POFailure(message: "Unable to resolve 3DS service, delegate is not set.", code: .generic(.mobile))
            }
            try await invoicesService.authorizeInvoice(request: authorizationRequest, threeDSService: threeDSService)
            didAuthorizeInvoice = true
        } catch {
            return .init(status: .failure, errors: [error])
        }
        return .init(status: .success, errors: nil)
    }

    @available(iOS 14.0, *)
    func paymentAuthorizationControllerDidRequestMerchantSessionUpdate(
        controller: POPassKitPaymentAuthorizationController
    ) async -> PKPaymentRequestMerchantSessionUpdate? {
        await delegate?.dynamicCheckoutPassKitPaymentDidRequestMerchantSessionUpdate()
    }

    @available(iOS 15.0, *)
    func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate? {
        await delegate?.dynamicCheckoutPassKitPayment(didChangeCouponCode: couponCode)
    }

    func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didSelectShippingMethod shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate? {
        await delegate?.dynamicCheckoutPassKitPayment(didSelectShippingMethod: shippingMethod)
    }

    func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate? {
        await delegate?.dynamicCheckoutPassKitPayment(didSelectShippingContact: contact)
    }

    func paymentAuthorizationController(
        _ controller: POPassKitPaymentAuthorizationController,
        didSelectPaymentMethod paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate? {
        await delegate?.dynamicCheckoutPassKitPayment(didSelectPaymentMethod: paymentMethod)
    }
}
