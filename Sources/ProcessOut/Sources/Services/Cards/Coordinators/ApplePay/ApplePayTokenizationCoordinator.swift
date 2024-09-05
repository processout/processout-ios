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
        errorMapper: PassKitPaymentErrorMapper,
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
            let result = await delegate?.applePayTokenization(didTokenizePayment: payment, card: card)
            switch result?.status {
            case nil, .success:
                self.card = card
            default:
                break
            }
            return result ?? .init(status: .success, errors: nil)
        } catch {
            let errors = errorMapper.map(poError: error)
            return PKPaymentAuthorizationResult(status: .failure, errors: errors)
        }
    }

    // MARK: - Private Properties

    private let cardsService: POCardsService
    private let errorMapper: PassKitPaymentErrorMapper
    private let request: POApplePayTokenizationRequest
    private let delegate: POApplePayTokenizationDelegate?
}
