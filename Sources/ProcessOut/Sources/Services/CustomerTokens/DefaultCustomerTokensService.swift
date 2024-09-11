//
//  DefaultCustomerTokensService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

final class DefaultCustomerTokensService: POCustomerTokensService {

    init(repository: CustomerTokensRepository, threeDSService: ThreeDSService, logger: POLogger) {
        self.repository = repository
        self.threeDSService = threeDSService
        self.logger = logger
    }

    // MARK: - POCustomerTokensService

    func assignCustomerToken(
        request: POAssignCustomerTokenRequest, threeDSService: PO3DSService
    ) async throws -> POCustomerToken {
        let response = try await repository.assignCustomerToken(request: request)
        if let customerAction = response.customerAction {
            let newRequest: POAssignCustomerTokenRequest
            do {
                let newSource = try await self.threeDSService.handle(action: customerAction, delegate: threeDSService)
                newRequest = request.replacing(source: newSource)
            } catch {
                var attributes: [POLogAttributeKey: String] = [
                    .customerId: request.customerId, .customerTokenId: request.tokenId
                ]
                attributes[.invoiceId] = request.invoiceId
                logger.warn("Did fail to assign customer token: \(error)", attributes: attributes)
                throw error
            }
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
    private let logger: POLogger
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
            thirdPartySdkVersion: thirdPartySdkVersion,
            metadata: metadata
        )
        return updatedRequest
    }
}
