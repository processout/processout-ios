//
//  HttpCustomersRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.12.2024.
//

final class HttpCustomersRepository: CustomersRepository {

    init(connector: HttpConnector) {
        self.connector = connector
    }

    // MARK: - CustomersRepository

    func createCustomer(request: POCustomerCreationRequest) async throws -> POCustomer {
        struct Response: Decodable, Sendable {
            let customer: POCustomer
        }
        let httpRequest = HttpConnectorRequest<Response>.post(
            path: "/customers", body: request, requiresPrivateKey: true
        )
        return try await connector.execute(request: httpRequest).value.customer
    }

    // MARK: - Private Properties

    private let connector: HttpConnector
}
