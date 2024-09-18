//
//  CustomerActionsService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

protocol CustomerActionsService {

    /// Implementation should attempt to handle given customer action.
    /// - Parameters:
    ///   - action: customer action to handle.
    ///   - threeDSService: delegate that would perform 3DS2 handling
    func handle(action: _CustomerAction, threeDSService: PO3DSService) async throws -> String
}
