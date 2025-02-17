//
//  CustomersRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.12.2024.
//

protocol CustomersRepository: PORepository {

    /// Creates customer with given parameters.
    func createCustomer(request: POCustomerCreationRequest) async throws(Failure) -> POCustomer
}
