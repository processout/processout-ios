//
//  CardsRepository.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation

final class CardsRepository: POCardsRepositoryType {

    init(
        connector: HttpConnectorType,
        failureMapper: FailureMapperType,
        applePayCardTokenizationRequestMapper: ApplePayCardTokenizationRequestMapperType
    ) {
        self.connector = connector
        self.failureMapper = failureMapper
        self.applePayCardTokenizationRequestMapper = applePayCardTokenizationRequestMapper
    }

    // MARK: - POCardsRepositoryType

    func tokenize(request: POCardTokenizationRequest, completion: @escaping (Result<POCard, Failure>) -> Void) {
        let httpRequest = HttpConnectorRequest<CardTokenizationResponse>.post(
            path: "/cards", body: request, includesDeviceMetadata: true
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map(\.card).mapError(failureMapper.failure))
        }
    }

    func updateCvc(cardId: String, newCvc: String, completion: @escaping (Result<POCard, Failure>) -> Void) {
        let parameters: [String: String] = [
            "cvc": newCvc
        ]
        let httpRequest = HttpConnectorRequest<CardTokenizationResponse>.put(
            path: "/cards/" + cardId, body: parameters, includesDeviceMetadata: true
        )
        connector.execute(request: httpRequest) { [failureMapper] result in
            completion(result.map(\.card).mapError(failureMapper.failure))
        }
    }

    func tokenize(request: POApplePayCardTokenizationRequest, completion: @escaping (Result<POCard, Failure>) -> Void) {
        do {
            let request = try applePayCardTokenizationRequestMapper.tokenizationRequest(from: request)
            let httpRequest = HttpConnectorRequest<CardTokenizationResponse>.post(
                path: "/cards", body: request, includesDeviceMetadata: true
            )
            connector.execute(request: httpRequest) { [failureMapper] result in
                completion(result.map(\.card).mapError(failureMapper.failure))
            }
        } catch {
            let failure = POFailure(message: nil, code: .internal, underlyingError: error)
            completion(.failure(failure))
        }
    }

    // MARK: - Private Properties

    private let connector: HttpConnectorType
    private let failureMapper: FailureMapperType
    private let applePayCardTokenizationRequestMapper: ApplePayCardTokenizationRequestMapperType
}
