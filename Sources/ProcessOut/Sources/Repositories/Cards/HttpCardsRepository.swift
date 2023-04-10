//
//  HttpCardsRepository.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation

final class HttpCardsRepository: POCardsRepository {

    init(connector: HttpConnector, failureMapper: HttpConnectorFailureMapper) {
        self.connector = connector
        self.failureMapper = failureMapper
    }

    // MARK: - POCardsRepository

    func tokenize(request: POCardTokenizationRequest, completion: @escaping (Result<POCard, Failure>) -> Void) {
        let httpRequest = HttpConnectorRequest<CardTokenizationResponse>.post(
            path: "/cards", body: request, includesDeviceMetadata: true
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map(\.card).mapError(failureMapper.failure))
        }
    }

    func updateCard(request: POCardUpdateRequest, completion: @escaping (Result<POCard, Failure>) -> Void) {
        let httpRequest = HttpConnectorRequest<CardTokenizationResponse>.put(
            path: "/cards/" + request.cardId, body: request, includesDeviceMetadata: true
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map(\.card).mapError(failureMapper.failure))
        }
    }

    func tokenize(request: ApplePayCardTokenizationRequest, completion: @escaping (Result<POCard, Failure>) -> Void) {
        let httpRequest = HttpConnectorRequest<CardTokenizationResponse>.post(
            path: "/cards", body: request, includesDeviceMetadata: true
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map(\.card).mapError(failureMapper.failure))
        }
    }

    // MARK: - Private Properties

    private let connector: HttpConnector
    private let failureMapper: HttpConnectorFailureMapper
}
