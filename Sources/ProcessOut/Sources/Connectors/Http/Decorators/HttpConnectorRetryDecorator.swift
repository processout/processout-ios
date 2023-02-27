//
//  HttpConnectorRetryDecorator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation

final class HttpConnectorRetryDecorator: HttpConnectorType {

    init(connector: HttpConnectorType, retryStrategy: RetryStrategy) {
        self.connector = connector
        self.retryStrategy = retryStrategy
    }

    func execute<Value>(
        request: HttpConnectorRequest<Value>, completion: @escaping (Result<Value, HttpConnectorFailure>) -> Void
    ) -> POCancellableType {
        let operation = HttpConnectorRetryDecoratorOperation(
            connector: connector, retryStrategy: retryStrategy, request: request, completion: completion
        )
        operation.start()
        return operation
    }

    // MARK: - Private Properties

    private let connector: HttpConnectorType
    private let retryStrategy: RetryStrategy
}
