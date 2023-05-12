//
//  DefaultCardsService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.03.2023.
//

import Foundation

final class DefaultCardsService: POCardsService {

    init(
        repository: POCardsRepository,
        applePayCardTokenizationRequestMapper: ApplePayCardTokenizationRequestMapper
    ) {
        self.repository = repository
        self.applePayCardTokenizationRequestMapper = applePayCardTokenizationRequestMapper
    }

    // MARK: - POCardsService

    func tokenize(request: POCardTokenizationRequest, completion: @escaping (Result<POCard, Failure>) -> Void) {
        repository.tokenize(request: request, completion: completion)
    }

    func updateCard(request: POCardUpdateRequest, completion: @escaping (Result<POCard, Failure>) -> Void) {
        repository.updateCard(request: request, completion: completion)
    }

    func tokenize(request: POApplePayCardTokenizationRequest, completion: @escaping (Result<POCard, Failure>) -> Void) {
        do {
            let request = try applePayCardTokenizationRequestMapper.tokenizationRequest(from: request)
            repository.tokenize(request: request, completion: completion)
        } catch let failure as POFailure {
            completion(.failure(failure))
        } catch {
            let failure = POFailure(message: nil, code: .internal(.mobile), underlyingError: error)
            completion(.failure(failure))
        }
    }

    // MARK: - Private Properties

    private let repository: POCardsRepository
    private let applePayCardTokenizationRequestMapper: ApplePayCardTokenizationRequestMapper
}
