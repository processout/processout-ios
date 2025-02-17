//
//  CustomerActionsService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

protocol CustomerActionsService: POService {

    /// Implementation should attempt to handle given customer action.
    /// - Parameters:
    ///   - request: customer action request.
    ///   - threeDSService: delegate that would perform 3DS2 handling
    func handle(
        request: CustomerActionRequest, threeDSService: PO3DS2Service
    ) async throws(Failure) -> String
}
