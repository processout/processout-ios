//
//  DefaultCustomerTokensService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

final class DefaultCustomerTokensService: POCustomerTokensService {

    init(repository: CustomerTokensRepository, threeDSService: ThreeDSService) {
        self.repository = repository
        self.threeDSService = threeDSService
    }

    // MARK: - POCustomerTokensService

    func assignCustomerToken(
        request: POAssignCustomerTokenRequest,
        threeDSService threeDSServiceDelegate: PO3DSService,
        completion: @escaping (Result<POCustomerToken, POFailure>) -> Void
    ) {
        repository.assignCustomerToken(request: request) { [threeDSService] result in
            switch result {
            case let .success(response):
                if let customerAction = response.customerAction {
                    threeDSService.handle(action: customerAction, delegate: threeDSServiceDelegate) { result in
                        switch result {
                        case let .success(newSource):
                            self.assignCustomerToken(
                                request: request.replacing(source: newSource),
                                threeDSService: threeDSServiceDelegate,
                                completion: completion
                            )
                        case let .failure(failure):
                            completion(.failure(failure))
                        }
                    }
                } else if let token = response.token {
                    completion(.success(token))
                } else {
                    let failure = POFailure(code: .internal(.mobile))
                    completion(.failure(failure))
                }
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    func createCustomerToken(
        request: POCreateCustomerTokenRequest,
        completion: @escaping (Result<POCustomerToken, Failure>) -> Void
    ) {
        repository.createCustomerToken(request: request, completion: completion)
    }

    // MARK: - Private Properties

    private let repository: CustomerTokensRepository
    private let threeDSService: ThreeDSService
}

private extension POAssignCustomerTokenRequest { // swiftlint:disable:this no_extension_access_modifier

    func replacing(source newSource: String) -> Self {
        let updatedRequest = POAssignCustomerTokenRequest(
            customerId: customerId,
            tokenId: tokenId,
            source: newSource,
            preferredScheme: preferredScheme,
            verify: verify,
            invoiceId: invoiceId,
            enableThreeDS2: enableThreeDS2,
            thirdPartySdkVersion: thirdPartySdkVersion
        )
        return updatedRequest
    }
}
