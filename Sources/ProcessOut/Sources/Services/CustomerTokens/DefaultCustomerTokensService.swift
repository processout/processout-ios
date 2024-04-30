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
        request: POAssignCustomerTokenRequest, threeDSService: PO3DSService
    ) async throws -> POCustomerToken {
        let response = try await repository.assignCustomerToken(request: request)
        if let customerAction = response.customerAction {
            let newSource = try await self.threeDSService.handle(action: customerAction, delegate: threeDSService)
            let newRequest = request.replacing(source: newSource)
            return try await assignCustomerToken(request: newRequest, threeDSService: threeDSService)
        }
        if let token = response.token {
            return token
        }
        throw POFailure(code: .internal(.mobile)) // Either token or action should be set
    }

    func createCustomerToken(request: POCreateCustomerTokenRequest) async throws -> POCustomerToken {
        try await repository.createCustomerToken(request: request)
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
            thirdPartySdkVersion: thirdPartySdkVersion
        )
        return updatedRequest
    }
}
