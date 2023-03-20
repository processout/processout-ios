//
//  ThreeDSServiceType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

protocol ThreeDSServiceType {

    typealias Completion = (Result<String, POFailure>) -> Void

    /// Implementation should attempt to handle given customer action.
    /// - Parameters:
    ///   - customerAction: customer action to handle.
    ///   - delegate: delegate that would perform actual action handling.
    ///   - completion: closure to invoke with a result of customer action handling.
    func handle(action: ThreeDSCustomerAction, handler: PO3DSServiceType, completion: @escaping Completion)
}
