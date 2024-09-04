//
//  DefaultCardsService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.03.2023.
//

import Foundation
import PassKit

final class DefaultCardsService: POCardsService {

    init(
        repository: CardsRepository,
        applePayAuthorizationSession: ApplePayAuthorizationSession,
        applePayCardTokenizationRequestMapper: ApplePayCardTokenizationRequestMapper
    ) {
        self.repository = repository
        self.applePayAuthorizationSession = applePayAuthorizationSession
        self.applePayCardTokenizationRequestMapper = applePayCardTokenizationRequestMapper
    }

    // MARK: - POCardsService

    func issuerInformation(iin: String) async throws -> POCardIssuerInformation {
        try await repository.issuerInformation(iin: iin)
    }

    func tokenize(request: POCardTokenizationRequest) async throws -> POCard {
        try await repository.tokenize(request: request)
    }

    func updateCard(request: POCardUpdateRequest) async throws -> POCard {
        try await repository.updateCard(request: request)
    }

    func tokenize(request: POApplePayPaymentTokenizationRequest) async throws -> POCard {
        let request = try applePayCardTokenizationRequestMapper.tokenizationRequest(from: request)
        return try await repository.tokenize(request: request)
    }

    func tokenize(request: POApplePayTokenizationRequest) async throws -> POCard {
        let tokenizePayment = { (payment: PKPayment) async throws -> POCard in
            let paymentTokenizationRequest = POApplePayPaymentTokenizationRequest(
                payment: payment,
                merchantIdentifier: request.paymentRequest.merchantIdentifier,
                contact: request.contact,
                metadata: request.metadata
            )
            return try await self.tokenize(request: paymentTokenizationRequest)
        }
        return try await applePayAuthorizationSession.authorize(
            request: request.paymentRequest, didAuthorizePayment: tokenizePayment, delegate: nil
        )
    }

    // MARK: - Private Properties

    private let repository: CardsRepository
    private let applePayAuthorizationSession: ApplePayAuthorizationSession
    private let applePayCardTokenizationRequestMapper: ApplePayCardTokenizationRequestMapper
}
