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
            // swiftlint:disable:next line_length
            let result = await delegate?.applePayTokenization(didTokenizePayment: payment, card: card) ?? .init(status: .success, errors: nil)
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

    // MARK: - Private Properties

    private let cardsService: POCardsService
    private let errorMapper: PassKitPaymentErrorMapper
    private let request: POApplePayTokenizationRequest
    private let delegate: POApplePayTokenizationDelegate?
}
