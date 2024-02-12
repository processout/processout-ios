//
//  HttpConnectorErrorDecorator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.12.2023.
//

import Foundation

/// Transforms errors from underlying connector to `POFailure` instances.
final class HttpConnectorErrorDecorator: HttpConnector {

    init(connector: HttpConnector, failureMapper: HttpConnectorFailureMapper) {
        self.connector = connector
        self.failureMapper = failureMapper
    }

    func execute<Value>(request: HttpConnectorRequest<Value>) async throws -> Value {
        do {
            return try await connector.execute(request: request)
        } catch let error as HttpConnectorFailure {
            throw failureMapper.failure(from: error)
        } catch {
            assertionFailure("Expected HttpConnectorFailure error.")
            throw POFailure(code: .internal(.mobile), underlyingError: error)
        }
    }

    // MARK: - Private Properties

    private let connector: HttpConnector
    private let failureMapper: HttpConnectorFailureMapper
}
