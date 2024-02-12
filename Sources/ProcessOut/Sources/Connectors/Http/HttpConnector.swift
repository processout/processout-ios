//
//  HttpConnector.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

protocol HttpConnector: AnyObject {

    typealias Failure = HttpConnectorFailure

    /// Changes connector configuration.
    func configure(configuration: HttpConnectorConfiguration)

    /// Executes given request.
    /// - Parameters:
    ///   - request: request to execute.
    func execute<Value>(request: HttpConnectorRequest<Value>) async throws -> Value
}
