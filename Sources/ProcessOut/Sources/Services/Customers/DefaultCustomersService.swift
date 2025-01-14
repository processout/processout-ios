//
//  DefaultCustomersService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.12.2024.
//

import Foundation

final class DefaultCustomersService: POCustomersService {

    init(repository: CustomersRepository) {
        self.repository = repository
    }

    // MARK: - POCustomersService

    func createCustomer(request: POCustomerCreationRequest) async throws -> POCustomer {
        try await repository.createCustomer(request: request)
    }

    // MARK: - Private Properties

    private let repository: CustomersRepository
}
