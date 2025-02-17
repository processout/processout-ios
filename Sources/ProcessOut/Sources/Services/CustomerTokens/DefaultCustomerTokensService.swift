//
//  DefaultCustomerTokensService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

final class DefaultCustomerTokensService: POCustomerTokensService {

    init(
        repository: CustomerTokensRepository,
        customerActionsService: CustomerActionsService,
        eventEmitter: POEventEmitter,
        logger: POLogger
    ) {
        self.repository = repository
        self.customerActionsService = customerActionsService
        self.eventEmitter = eventEmitter
        self.logger = logger
    }

    // MARK: - POCustomerTokensService

    func assignCustomerToken(
        request: POAssignCustomerTokenRequest, threeDSService: PO3DS2Service
    ) async throws(Failure) -> POCustomerToken {
        do {
            let customerToken = try await _assignCustomerToken(request: request, threeDSService: threeDSService)
            await threeDSService.clean()
            return customerToken
        } catch {
            await threeDSService.clean()
            throw error
        }
    }

    func deleteCustomerToken(request: PODeleteCustomerTokenRequest) async throws(Failure) {
        try await repository.delete(request: request)
        eventEmitter.emit(event: POCustomerTokenDeletedEvent(customerId: request.customerId, tokenId: request.tokenId))
    }

    func createCustomerToken(request: POCreateCustomerTokenRequest) async throws(Failure) -> POCustomerToken {
        try await repository.createCustomerToken(request: request)
    }

    // MARK: - Private Properties

    private let repository: CustomerTokensRepository
    private let customerActionsService: CustomerActionsService
    private let eventEmitter: POEventEmitter
    private let logger: POLogger

    // MARK: - Private Methods

    private func _assignCustomerToken(
        request: POAssignCustomerTokenRequest, threeDSService: PO3DS2Service
    ) async throws(Failure) -> POCustomerToken {
        let response = try await repository.assignCustomerToken(request: request)
        if let customerAction = response.customerAction {
            let newRequest: POAssignCustomerTokenRequest
            do {
                let customerActionRequest = CustomerActionRequest(
                    customerAction: customerAction,
                    webAuthenticationCallback: request.webAuthenticationCallback,
                    prefersEphemeralWebAuthenticationSession: true
                )
                let newSource = try await customerActionsService.handle(
                    request: customerActionRequest, threeDSService: threeDSService
                )
                newRequest = request.replacing(source: newSource)
            } catch {
                var attributes: [POLogAttributeKey: String] = [
                    .customerId: request.customerId, .customerTokenId: request.tokenId
                ]
                attributes[.invoiceId] = request.invoiceId
                logger.warn("Did fail to assign customer token: \(error)", attributes: attributes)
                throw error
            }
            return try await _assignCustomerToken(request: newRequest, threeDSService: threeDSService)
        }
        if let token = response.token {
            return token
        }
        logger.error("Unexpected response, either token or action should be set.")
        throw POFailure(message: "Unable to assign customer token.", code: .Mobile.internal)
    }
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
            metadata: metadata,
            webAuthenticationCallback: webAuthenticationCallback
        )
        return updatedRequest
    }
}
