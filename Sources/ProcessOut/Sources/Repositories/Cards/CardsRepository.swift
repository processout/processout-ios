//
//  CardsRepository.swift
//  
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation

final class CardsRepository: POCardsRepositoryType {
    init(
        connector: HttpConnectorType,
        failureFactory: RepositoryFailureFactoryType,
        applePayCardTokenizationRequestFactory: ApplePayCardTokenizationRequestFactoryType
    ) {
        self.connector = connector
        self.failureFactory = failureFactory
        self.applePayCardTokenizationRequestFactory = applePayCardTokenizationRequestFactory
    }

    // MARK: - POCardsRepositoryType

    func tokenize(
        request: POCardTokenizationRequest,
        completion: @escaping (Result<POCard, Failure>) -> Void
    ) {
        let httpRequest = HttpConnectorRequest<CardTokenizationResponse>.post(
            path: "/cards", body: request
        )
        connector.execute(request: httpRequest) { [failureFactory] result in
            completion(result.map(\.card).mapError(failureFactory.repositoryFailure))
        }
    }

    func updateCvc(
        cardId: String,
        newCvc: String,
        completion: @escaping (Result<POCard, Failure>) -> Void
    ) {
        let parameters: [String: String] = [
            "cvc": newCvc
        ]
        let httpRequest = HttpConnectorRequest<CardTokenizationResponse>.put(
            path: "/cards/" + cardId, body: parameters
        )
        connector.execute(request: httpRequest) { [failureFactory] result in
            completion(result.map(\.card).mapError(failureFactory.repositoryFailure))
        }
    }

    func tokenize(
        request: POApplePayCardTokenizationRequest,
        completion: @escaping (Result<POCard, Failure>) -> Void
    ) {
        do {
            let request = try applePayCardTokenizationRequestFactory.tokenizationRequest(from: request)
            let httpRequest = HttpConnectorRequest<CardTokenizationResponse>.post(
                path: "/cards", body: request
            )
            connector.execute(request: httpRequest) { [failureFactory] result in
                completion(result.map(\.card).mapError(failureFactory.repositoryFailure))
            }
        } catch {
            let failure = PORepositoryFailure(message: nil, code: .internal, underlyingError: error)
            completion(.failure(failure))
        }
    }

    // MARK: - Private Properties

    private let connector: HttpConnectorType
    private let failureFactory: RepositoryFailureFactoryType
    private let applePayCardTokenizationRequestFactory: ApplePayCardTokenizationRequestFactoryType
}
