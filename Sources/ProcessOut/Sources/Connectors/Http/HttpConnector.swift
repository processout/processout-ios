//
//  HttpConnector.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

protocol HttpConnector<Failure>: Sendable {

    associatedtype Failure: Error

    /// Executes given request and returns response object with both value and metadata.
    /// - Parameters:
    ///   - request: request to execute.
    func execute<Value>(request: HttpConnectorRequest<Value>) async throws(Failure) -> HttpConnectorResponse<Value>

    /// Replaces existing connector configuration.
    func replace(configuration: HttpConnectorConfiguration)
}

extension HttpConnector {

    /// Executes given request.
    /// - Parameters:
    ///   - request: request to execute.
    func execute<Value>(request: HttpConnectorRequest<Value>) async throws(Failure) -> Value {
        try await execute(request: request).value
    }
}
