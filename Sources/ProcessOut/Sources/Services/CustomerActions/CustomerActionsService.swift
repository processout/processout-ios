//
//  CustomerActionsService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

protocol CustomerActionsService: POService {

    /// Implementation should attempt to handle given customer action.
    /// - Parameters:
    ///   - action: customer action to handle.
    ///   - threeDSService: delegate that would perform 3DS2 handling
    ///   - callback: An object used to evaluate navigation events in a web authentication session.
    func handle(
        action: _CustomerAction, threeDSService: PO3DS2Service, callback: POWebAuthenticationCallback?
    ) async throws -> String
}
