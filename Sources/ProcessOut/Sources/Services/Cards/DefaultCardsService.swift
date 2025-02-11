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
        applePayCardTokenizationRequestMapper: ApplePayCardTokenizationRequestMapper,
        applePayErrorMapper: POPassKitPaymentErrorMapper
    ) {
        self.repository = repository
        self.applePayAuthorizationSession = applePayAuthorizationSession
        self.applePayCardTokenizationRequestMapper = applePayCardTokenizationRequestMapper
        self.applePayErrorMapper = applePayErrorMapper
    }

    // MARK: - POCardsService

    func issuerInformation(iin cardNumber: String) async throws -> POCardIssuerInformation {
        // todo(andrii-vysotskyi): indicate in method arguments that method accepts full card number
        let iin = try issuerIdentificationNumber(of: cardNumber)
        return try await repository.issuerInformation(iin: iin)
    }

    func tokenize(request: POCardTokenizationRequest) async throws -> POCard {
        try await repository.tokenize(request: request)
    }

    func updateCard(request: POCardUpdateRequest) async throws -> POCard {
        try await repository.updateCard(request: request)
    }

    @MainActor
    func tokenize(request: POApplePayPaymentTokenizationRequest) async throws -> POCard {
        let request = try applePayCardTokenizationRequestMapper.tokenizationRequest(from: request)
        return try await repository.tokenize(request: request)
    }

    @MainActor
    func tokenize(
        request: POApplePayTokenizationRequest, delegate: POApplePayTokenizationDelegate?
    ) async throws -> POCard {
        let coordinator = ApplePayTokenizationCoordinator(
            cardsService: self, errorMapper: applePayErrorMapper, request: request, delegate: delegate
        )
        _ = try await applePayAuthorizationSession.authorize(
            request: request.paymentRequest, delegate: coordinator
        )
        guard let card = coordinator.card else {
            throw POFailure(message: "Tokenization was cancelled.", code: .Mobile.cancelled)
        }
        return card
    }

    // MARK: - Private Properties

    private let repository: CardsRepository
    private let applePayAuthorizationSession: ApplePayAuthorizationSession
    private let applePayCardTokenizationRequestMapper: ApplePayCardTokenizationRequestMapper
    private let applePayErrorMapper: POPassKitPaymentErrorMapper

    // MARK: - Private Methods

    private func issuerIdentificationNumber(of cardNumber: String) throws -> String {
        let iinLength: Int, filteredNumber = cardNumber.filter(\.isNumber)
        if filteredNumber.count >= 8 {
            iinLength = 8
        } else if filteredNumber.count >= 6 {
            iinLength = 6
        } else {
            throw POFailure(message: "IIN must have at least 6 digits.", code: .Mobile.generic)
        }
        return String(filteredNumber.prefix(iinLength))
    }
}
