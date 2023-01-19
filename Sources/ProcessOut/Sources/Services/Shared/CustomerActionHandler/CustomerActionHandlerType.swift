//
//  CustomerActionHandlerType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

protocol CustomerActionHandlerType {

    typealias Delegate = POCustomerActionHandlerDelegate

    /// Implementation should attempt to handle given customer action.
    /// - Parameters:
    ///   - customerAction: customer action to handle.
    ///   - delegate: delegate that would perform actual action handling.
    ///   - completion: closure to invoke with a result of customer action handling.
    func handle(
        customerAction: _CustomerAction,
        delegate: Delegate,
        completion: @escaping (Result<String, POFailure>) -> Void
    )
}
