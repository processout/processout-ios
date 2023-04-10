//
//  ThreeDSService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

protocol ThreeDSService {

    typealias Delegate = PO3DSService

    /// Implementation should attempt to handle given customer action.
    /// - Parameters:
    ///   - action: customer action to handle.
    ///   - delegate: delegate that would perform actual action handling.
    ///   - completion: closure to invoke with a result of customer action handling.
    func handle(
        action: ThreeDSCustomerAction, delegate: Delegate, completion: @escaping (Result<String, POFailure>) -> Void
    )
}
