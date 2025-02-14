//
//  HttpConnectorRetryDecorator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation

final class HttpConnectorRetryDecorator: HttpConnector {

    init(connector: any HttpConnector<Failure>, retryStrategy: RetryStrategy) {
        self.connector = connector
        self.retryStrategy = retryStrategy
    }

    // MARK: - HttpConnector

    typealias Failure = HttpConnectorFailure

    func execute<Value>(
        request: HttpConnectorRequest<Value>
    ) async throws(Failure) -> HttpConnectorResponse<Value> {
        let updatedRequest = addingIdempotencyKey(request: request)
        return try await retry(
            operation: { [connector] () throws(Failure) in
                try await connector.execute(request: updatedRequest)
            },
            while: { result in
                guard case .failure(let failure) = result else {
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
            timeoutError: .init(code: .timeout, underlyingError: nil),
            retryStrategy: retryStrategy
        )
    }

    func replace(configuration: HttpConnectorConfiguration) {
        connector.replace(configuration: configuration)
    }

    // MARK: - Private Properties

    private let connector: any HttpConnector<Failure>
    private let retryStrategy: RetryStrategy

    // MARK: - Private Methods

    private func addingIdempotencyKey<Value>(request: HttpConnectorRequest<Value>) -> HttpConnectorRequest<Value> {
        var updatedHeaders = request.headers
        switch request.method {
        case .get:
            return request
        case .post, .put, .delete:
            updatedHeaders["Idempotency-Key"] = UUID().uuidString
        }
        let request = HttpConnectorRequest(
            id: request.id,
            method: request.method,
            path: request.path,
            query: request.query,
            body: request.body,
            headers: updatedHeaders,
            includesDeviceMetadata: request.includesDeviceMetadata,
            requiresPrivateKey: request.requiresPrivateKey
        )
        return request
    }
}
