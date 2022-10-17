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
    ) {
        var retriesCount = 0
        var completionTrampoline: ((Result<Value, HttpConnectorFailure>) -> Void)?
        completionTrampoline = { [retryStrategy] result in
            guard case .failure(let failure) = result,
                  HttpConnectorRetryDecorator.shouldRetryRequest(after: failure),
                  retriesCount < retryStrategy.maximumRetries else {
                completion(result)
                return
            }
            let delay = self.retryStrategy.interval(for: retriesCount)
            retriesCount += 1
            Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                self.connector.execute(request: request, completion: completionTrampoline ?? completion)
            }
        }
        connector.execute(request: request, completion: completionTrampoline ?? completion)
    }

    // MARK: - Private Properties

    private let connector: HttpConnectorType
    private let retryStrategy: RetryStrategy

    // MARK: - Private Methods

    private static func shouldRetryRequest(after failure: HttpConnectorFailure) -> Bool {
        switch failure {
        case .networkUnreachable:
            return true
        case .external(_, let statusCode):
            return (500...599).contains(statusCode)
        default:
            return false
        }
    }
}
