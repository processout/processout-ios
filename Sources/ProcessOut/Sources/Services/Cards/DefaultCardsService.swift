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

    func tokenize(
        request: POApplePayTokenizationRequest, delegate: POApplePayTokenizationDelegate?
    ) async throws -> POCard {
        let coordinator = ApplePayTokenizationCoordinator(
            cardsService: self, request: request, delegate: delegate
        )
        _ = try await applePayAuthorizationSession.authorize(request: request.paymentRequest, delegate: coordinator)
        guard let card = coordinator.card else {
            throw POFailure(message: "Tokenization was cancelled.", code: .cancelled)
        }
        return card
    }

    // MARK: - Private Properties

    private let repository: CardsRepository
    private let applePayAuthorizationSession: ApplePayAuthorizationSession
    private let applePayCardTokenizationRequestMapper: ApplePayCardTokenizationRequestMapper
}
