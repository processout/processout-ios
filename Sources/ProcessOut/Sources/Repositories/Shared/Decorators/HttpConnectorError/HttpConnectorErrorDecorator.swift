//
//  HttpConnectorErrorDecorator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.12.2023.
//

import Foundation

/// Transforms errors from underlying connector to `POFailure` instances.
final class HttpConnectorErrorDecorator: HttpConnector {

    typealias Failure = POFailure

    init(connector: any HttpConnector<HttpConnectorFailure>, failureMapper: HttpConnectorFailureMapper) {
        self.connector = connector
        self.failureMapper = failureMapper
    }

    func execute<Value>(request: HttpConnectorRequest<Value>) async throws(POFailure) -> HttpConnectorResponse<Value> {
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
}
