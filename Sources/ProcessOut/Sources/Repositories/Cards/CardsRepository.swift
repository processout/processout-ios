//
//  CardsRepository.swift
//  
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation

final class CardsRepository: POCardsRepositoryType {
    init(connector: HttpConnectorType, failureFactory: RepositoryFailureFactoryType) {
        self.connector = connector
        self.failureFactory = failureFactory
    }
    
    // MARK: - POCardsRepositoryType
    
    func tokenize(request: POCardTokenizationRequest, completion: @escaping (Result<POCardTokenizationResponse, Failure>) -> Void) {
        let httpRequest = HttpConnectorRequest<POCardTokenizationResponse>.post(
            path: "/cards", body: request
        )
        connector.execute(request: httpRequest) { [failureFactory] result in
            completion(result.mapError(failureFactory.repositoryFailure))
        }
    }

    func updateCvc(cardId: String, newCvc: String, completion: @escaping (Result<POCardTokenizationResponse, Failure>) -> Void) {
        let parameters: [String: String] = [
            "cvc": newCvc
        ]
        let httpRequest = HttpConnectorRequest<POCardTokenizationResponse>.put(
            path: "/cards/" + cardId, body: parameters
        )
        connector.execute(request: httpRequest) { [failureFactory] result in
            completion(result.mapError(failureFactory.repositoryFailure))
        }
    }

    // MARK: - Private Properties

    private let connector: HttpConnectorType
    private let failureFactory: RepositoryFailureFactoryType
}
