//
//  HttpConnectorRetryDecorator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation

final class HttpConnectorRetryDecorator: HttpConnector {

    init(connector: HttpConnector, retryStrategy: RetryStrategy) {
        self.connector = connector
        self.retryStrategy = retryStrategy
    }

    func execute<Value>(request: HttpConnectorRequest<Value>) async throws -> HttpConnectorResponse<Value> {
        try await retry(
            operation: { [connector] in
                try await connector.execute(request: request)
            },
            while: { result in
                guard case .failure(let failure as Failure) = result else {
                    return false
                }
                switch failure.code {
                case .networkUnreachable, .timeout:
                    return true
                case .server(_, let statusCode), .decoding(let statusCode):
                    let clientErrors: Set = [408, 409, 425, 429]
                    let serverErrors = (500...599)
                    return clientErrors.contains(statusCode) || serverErrors.contains(statusCode)
                default:
                    return false
                }
            },
            timeout: 3600, // 1 hour
            timeoutError: HttpConnectorFailure(code: .timeout, underlyingError: nil),
            retryStrategy: retryStrategy
        )
    }

    func replace(configuration: HttpConnectorConfiguration) {
        connector.replace(configuration: configuration)
    }

    // MARK: - Private Properties

    private let connector: HttpConnector
    private let retryStrategy: RetryStrategy
}
