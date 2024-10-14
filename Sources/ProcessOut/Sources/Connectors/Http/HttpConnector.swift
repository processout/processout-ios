//
//  HttpConnector.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

protocol HttpConnector: AnyObject, Sendable {

    typealias Failure = HttpConnectorFailure

    /// Executes given request and returns response object with both value and metadata.
    /// - Parameters:
    ///   - request: request to execute.
    func execute<Value>(request: HttpConnectorRequest<Value>) async throws -> HttpConnectorResponse<Value>

    /// Replaces existing connector configuration.
    func replace(configuration: HttpConnectorRequestMapperConfiguration)
}

extension HttpConnector {

    /// Executes given request.
    /// - Parameters:
    ///   - request: request to execute.
    func execute<Value>(request: HttpConnectorRequest<Value>) async throws -> Value {
        try await execute(request: request).value
    }
}
