//
//  HttpConnectorType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

protocol HttpConnectorType: AnyObject {

    typealias Failure = HttpConnectorFailure

    /// Executes given request.
    /// - Parameters:
    ///   - request: request to execute.
    ///   - completion: completion is invoked after request execution completes with either success or failure.
    /// Will be called on main queue.
    func execute<Value>(
        request: HttpConnectorRequest<Value>, completion: @escaping (Result<Value, Failure>) -> Void
    )
}
