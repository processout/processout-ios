//
//  POCustomerTokensService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

final class CustomerTokensService: POCustomerTokensServiceType {

    init(repository: CustomerTokensRepositoryType, customerActionHandler: CustomerActionHandlerType) {
        self.repository = repository
        self.customerActionHandler = customerActionHandler
    }

    // MARK: - POCustomerTokensServiceType

    func assignCustomerToken(
        request: POAssignCustomerTokenRequest,
        customerActionHandlerDelegate: POCustomerActionHandlerDelegate,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        repository.assignCustomerToken(request: request) { [customerActionHandler] result in
            switch result {
            case let .success(customerAction?):
                let delegate = customerActionHandlerDelegate
                customerActionHandler.handle(customerAction: customerAction, delegate: delegate) { result in
                    switch result {
                    case let .success(newSource):
                        self.assignCustomerToken(
                            request: request.replacing(source: newSource),
                            customerActionHandlerDelegate: customerActionHandlerDelegate,
                            completion: completion
                        )
                    case let .failure(failure):
                        completion(.failure(failure))
                    }
                }
            case .success:
                completion(.success(()))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }

    func createCustomerToken(
        request: POCustomerTokenCreationRequest,
        completion: @escaping (Result<POCustomerToken, Failure>) -> Void
    ) {
        repository.createCustomerToken(request: request, completion: completion)
    }

    // MARK: - Private Properties

    private let repository: CustomerTokensRepositoryType
    private let customerActionHandler: CustomerActionHandlerType
}

private extension POAssignCustomerTokenRequest { // swiftlint:disable:this no_extension_access_modifier

    func replacing(source newSource: String) -> Self {
        let updatedRequest = POAssignCustomerTokenRequest(
            customerId: customerId,
            source: newSource,
            enableThreeDS2: enableThreeDS2,
            preferredScheme: preferredScheme,
            thirdPartySdkVersion: thirdPartySdkVersion,
            verify: verify,
            tokenId: tokenId
        )
        return updatedRequest
    }
}
