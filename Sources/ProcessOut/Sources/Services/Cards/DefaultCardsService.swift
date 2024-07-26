//
//  DefaultCardsService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.03.2023.
//

import Foundation

final class DefaultCardsService: POCardsService {

    init(
        repository: CardsRepository,
        applePayCardTokenizationRequestMapper: ApplePayCardTokenizationRequestMapper
    ) {
        self.repository = repository
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

    func tokenize(request: POApplePayCardTokenizationRequest) async throws -> POCard {
        let request = try await applePayCardTokenizationRequestMapper.tokenizationRequest(from: request)
        return try await repository.tokenize(request: request)
    }

    // MARK: - Private Properties

    private let repository: CardsRepository
    private let applePayCardTokenizationRequestMapper: ApplePayCardTokenizationRequestMapper
}
