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

    // MARK: - HttpConnector

    func configure(configuration: HttpConnectorRequestMapperConfiguration) {
        connector.configure(configuration: configuration)
    }

    func execute<Value>(request: HttpConnectorRequest<Value>) async throws -> Value {
        try await retry(
            operation: { [connector] in
                try await connector.execute(request: request)
            },
            while: { result in
                guard case .failure(let failure as Failure) = result else {
                    return false
                }
                switch failure {
                case .networkUnreachable, .timeout:
                    return true
                case .server(_, let statusCode),
                     .decoding(_, let statusCode):
                    return (500...599).contains(statusCode) || statusCode == 408
                default:
                    return false
                }
            },
            timeout: 3600, // 1 hour
            timeoutError: HttpConnectorFailure.timeout,
            retryStrategy: retryStrategy
        )
    }

    // MARK: - Private Properties

    private let connector: HttpConnector
    private let retryStrategy: RetryStrategy
}
