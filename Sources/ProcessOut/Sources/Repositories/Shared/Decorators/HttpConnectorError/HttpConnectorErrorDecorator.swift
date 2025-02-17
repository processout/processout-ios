//
//  HttpConnectorErrorDecorator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.12.2023.
//

import Foundation

/// Transforms errors from underlying connector to `POFailure` instances.
final class HttpConnectorErrorDecorator: HttpConnector {

    init(
        connector: any HttpConnector<HttpConnectorFailure>,
        failureMapper: HttpConnectorFailureMapper,
        logger: POLogger
    ) {
        self.connector = connector
        self.failureMapper = failureMapper
        self.logger = logger
    }

    // MARK: - HttpConnector

    typealias Failure = POFailure

    func execute<Value>(request: HttpConnectorRequest<Value>) async throws(Failure) -> HttpConnectorResponse<Value> {
        do {
            return try await connector.execute(request: request)
        } catch {
            throw failureMapper.failure(from: error)
        }
    }

    func replace(configuration: HttpConnectorConfiguration) {
        connector.replace(configuration: configuration)
    }

    // MARK: - Private Properties

    private let connector: any HttpConnector<HttpConnectorFailure>
    private let failureMapper: HttpConnectorFailureMapper
    private let logger: POLogger
}
