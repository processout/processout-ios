//
//  HttpConnectorAuthDecorator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.03.2023.
//

import Foundation

final class HttpConnectorAuthDecorator: HttpConnectorType {

    init(connector: HttpConnectorType, logger: POLogger, credentials: HttpConnectorAuthCredentials) {
        self.connector = connector
        self.logger = logger
        self.credentials = credentials
    }

    // MARK: - HttpConnectorType

    func execute<Value>(
        request: HttpConnectorRequest<Value>, completion: @escaping (Result<Value, HttpConnectorFailure>) -> Void
    ) -> POCancellableType {
        var headers: [String: String] = request.headers
        headers[Constants.authorizationHeaderKey] = authorizationHeaderValue(request: request)
        let authenticatedRequest = HttpConnectorRequest<Value>(
            id: request.id,
            method: request.method,
            path: request.path,
            query: request.query,
            body: request.body,
            headers: headers,
            includesDeviceMetadata: request.includesDeviceMetadata,
            requiresPrivateKey: request.requiresPrivateKey
        )
        return connector.execute(request: authenticatedRequest, completion: completion)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let authorizationHeaderKey = "Authorization"
        static let basicAuthorizationPrefix = "Basic "
    }

    // MARK: - Private Properties

    private let connector: HttpConnectorType
    private let logger: POLogger
    private let credentials: HttpConnectorAuthCredentials

    // MARK: - Private Methods

    private func authorizationHeaderValue(request: HttpConnectorRequest<some Decodable>) -> String {
        var value = credentials.projectId + ":"
        if request.requiresPrivateKey {
            if let privateKey = credentials.privateKey {
                value += privateKey
            } else {
                logger.info("Private key is required by '\(request.id)' request but not set")
            }
        }
        return Constants.basicAuthorizationPrefix + Data(value.utf8).base64EncodedString()
    }
}
