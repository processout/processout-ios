//
//  HttpConnectorErrorDecorator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.12.2023.
//

import Foundation

/// Transforms errors from underlying connector to `POFailure` instances.
final class HttpConnectorErrorDecorator: HttpConnector {

    init(connector: HttpConnector, failureMapper: HttpConnectorFailureMapper, logger: POLogger) {
        self.connector = connector
        self.failureMapper = failureMapper
        self.logger = logger
    }

    func execute<Value>(request: HttpConnectorRequest<Value>) async throws -> HttpConnectorResponse<Value> {
        do {
            return try await connector.execute(request: request)
        } catch let error as HttpConnectorFailure {
            throw failureMapper.failure(from: error)
        } catch {
            logger.error("Unexpected error: \(error).")
            throw POFailure(message: "Something went wrong.", code: .Mobile.internal, underlyingError: error)
        }
    }

    func replace(configuration: HttpConnectorConfiguration) {
        connector.replace(configuration: configuration)
    }

    // MARK: - Private Properties

    private let connector: HttpConnector
    private let failureMapper: HttpConnectorFailureMapper
    private let logger: POLogger
}
