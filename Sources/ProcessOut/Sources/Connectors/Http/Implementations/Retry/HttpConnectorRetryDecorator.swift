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

    func execute<Value>(request: HttpConnectorRequest<Value>) async throws -> Value {
        do {
            return try await connector.execute(request: request)
        } catch {
            return try await retry(request: request, error: error, attempt: 0)
        }
    }

    // MARK: - Private Properties

    private let connector: HttpConnector
    private let retryStrategy: RetryStrategy

    // MARK: - Private Methods

    private func retry<Value>(request: HttpConnectorRequest<Value>, error: Error, attempt: Int) async throws -> Value {
        guard shouldRetry(after: error), attempt < retryStrategy.maximumRetries else {
            throw error
        }
        do {
            let delay = retryStrategy.interval(for: attempt)
            try await Task.sleep(nanoseconds: UInt64(delay * 1e9))
        } catch {
            throw Failure.cancelled
        }
        do {
            return try await connector.execute(request: request)
        } catch {
            return try await retry(request: request, error: error, attempt: attempt + 1)
        }
    }

    private func shouldRetry(after error: Error) -> Bool {
        guard let failure = error as? Failure else {
            assertionFailure("Unexpected error type \(error).")
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
    }
}
