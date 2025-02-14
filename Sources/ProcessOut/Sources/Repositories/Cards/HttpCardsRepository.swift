//
//  HttpCardsRepository.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation

final class HttpCardsRepository: CardsRepository {

    init(connector: any HttpConnector<Failure>) {
        self.connector = connector
    }

    // MARK: - CardsRepository

    func issuerInformation(iin: String) async throws(Failure) -> POCardIssuerInformation {
        struct Response: Decodable, Sendable {
            let cardInformation: POCardIssuerInformation
        }
        let httpRequest = HttpConnectorRequest<Response>.get(path: "/iins/" + iin)
        return try await connector.execute(request: httpRequest).cardInformation
    }

    func tokenize(request: POCardTokenizationRequest) async throws(Failure) -> POCard {
        let httpRequest = HttpConnectorRequest<CardTokenizationResponse>.post(
            path: "/cards", body: request, includesDeviceMetadata: true
        )
        return try await connector.execute(request: httpRequest).card
    }

    func updateCard(request: POCardUpdateRequest) async throws(Failure) -> POCard {
        let httpRequest = HttpConnectorRequest<CardTokenizationResponse>.put(
            path: "/cards/" + request.cardId, body: request, includesDeviceMetadata: true
        )
        return try await connector.execute(request: httpRequest).card
    }

    func tokenize(request: ApplePayCardTokenizationRequest) async throws(Failure) -> POCard {
        let httpRequest = HttpConnectorRequest<CardTokenizationResponse>.post(
            path: "/cards", body: request, includesDeviceMetadata: true
        )
        return try await connector.execute(request: httpRequest).card
    }

    // MARK: - Private Properties

    private let connector: any HttpConnector<Failure>
}
