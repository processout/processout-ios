//
//  ApplePayTokenizationCoordinator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.09.2024.
//

import PassKit

final class ApplePayTokenizationCoordinator: ApplePayAuthorizationSessionDelegate {

    init(
        cardsService: POCardsService,
        errorMapper: POPassKitPaymentErrorMapper,
        request: POApplePayTokenizationRequest,
        delegate: POApplePayTokenizationDelegate?
    ) {
        self.cardsService = cardsService
        self.errorMapper = errorMapper
        self.request = request
        self.delegate = delegate
    }

    var card: POCard?

    // MARK: - ApplePayAuthorizationSessionDelegate

    func applePayAuthorizationSession(
        didAuthorizePayment payment: PKPayment
    ) async -> PKPaymentAuthorizationResult {
        let paymentTokenizationRequest = POApplePayPaymentTokenizationRequest(
            payment: payment,
            merchantIdentifier: request.paymentRequest.merchantIdentifier,
            contact: request.contact,
            metadata: request.metadata
        )
        do {
            let card = try await cardsService.tokenize(request: paymentTokenizationRequest)
            // swiftlint:disable:next line_length
            let result = await delegate?.applePayTokenization(didAuthorizePayment: payment, card: card) ?? .init(status: .success, errors: nil)
            if case .success = result.status {
                self.card = card
            }
            result.errors = result.errors.flatMap(errorMapper.map)
            return result
        } catch {
            let errors = errorMapper.map(poError: error)
            return PKPaymentAuthorizationResult(status: .failure, errors: errors)
        }
    }

    func applePayAuthorizationSessionWillAuthorizePayment() {
        delegate?.applePayTokenizationWillAuthorizePayment()
    }

    @available(iOS 14.0, *)
    func applePayAuthorizationSessionDidRequestMerchantSessionUpdate() async -> PKPaymentRequestMerchantSessionUpdate? {
        await delegate?.applePayTokenizationDidRequestMerchantSessionUpdate()
    }

    @available(iOS 15.0, *)
    func applePayAuthorizationSession(
        didChangeCouponCode couponCode: String
    ) async -> PKPaymentRequestCouponCodeUpdate? {
        let update = await delegate?.applePayTokenization(didChangeCouponCode: couponCode)
        update?.errors = update?.errors.flatMap(errorMapper.map)
        return update
    }

    func applePayAuthorizationSession(
        didSelectShippingMethod shippingMethod: PKShippingMethod
    ) async -> PKPaymentRequestShippingMethodUpdate? {
        await delegate?.applePayTokenization(didSelectShippingMethod: shippingMethod)
    }

    func applePayAuthorizationSession(
        didSelectShippingContact contact: PKContact
    ) async -> PKPaymentRequestShippingContactUpdate? {
        let update = await delegate?.applePayTokenization(didSelectShippingContact: contact)
        update?.errors = update?.errors.flatMap(errorMapper.map)
        return update
    }

    func applePayAuthorizationSession(
        didSelectPaymentMethod paymentMethod: PKPaymentMethod
    ) async -> PKPaymentRequestPaymentMethodUpdate? {
        let update = await delegate?.applePayTokenization(didSelectPaymentMethod: paymentMethod)
        update?.errors = update?.errors.flatMap(errorMapper.map)
        return update
    }

    // MARK: - Private Properties

    private let cardsService: POCardsService
    private let errorMapper: POPassKitPaymentErrorMapper
    private let request: POApplePayTokenizationRequest
    private let delegate: POApplePayTokenizationDelegate?
}
