//
//  HttpConnector.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation

protocol HttpConnector: AnyObject {

    typealias Failure = HttpConnectorFailure

    /// Executes given request.
    /// - Parameters:
    ///   - request: request to execute.
    func execute<Value>(request: HttpConnectorRequest<Value>) async throws -> Value
}

extension HttpConnector {

    /// Executes given request.
    ///
    /// - Parameters:
    ///   - request: request to execute.
    ///   - completion: completion is invoked after request execution completes with either success or failure.
    /// Will be called on main queue.
    @discardableResult
    func execute<Value>(
        request: HttpConnectorRequest<Value>, completion: @escaping (Result<Value, Failure>) -> Void
    ) -> POCancellable {
        let task = Task { @MainActor in
            let result: Result<Value, Failure>
            do {
                let value = try await execute(request: request)
                result = .success(value)
            } catch let failure as Failure {
                result = .failure(failure)
            } catch {
                result = .failure(.internal)
            }
            completion(result)
        }
        let cancellable = GroupCancellable()
        cancellable.add(task)
        return cancellable
    }
}

extension Task: POCancellable { }
