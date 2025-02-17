//
//  POCustomersService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.12.2024.
//

@_spi(PO)
public protocol POCustomersService: POService {

    /// Creates customer with given parameters.
    func createCustomer(request: POCustomerCreationRequest) async throws(Failure) -> POCustomer
}
