//
//  DefaultHttpConnectorRequestMapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2023.
//

import Foundation

final class DefaultHttpConnectorRequestMapper: HttpConnectorRequestMapper {

    init(
        configuration: HttpConnectorRequestMapperConfiguration,
        encoder: JSONEncoder,
        deviceMetadataProvider: DeviceMetadataProvider,
        logger: POLogger
    ) {
        self.configuration = configuration
        self.encoder = encoder
        self.deviceMetadataProvider = deviceMetadataProvider
        self.logger = logger
    }

    func urlRequest(from request: HttpConnectorRequest<some Decodable>) throws -> URLRequest {
        guard var components = URLComponents(url: configuration.baseUrl, resolvingAgainstBaseURL: true) else {
            logger.error("Unable to create a request with base URL \(configuration.baseUrl)")
            throw HttpConnectorFailure.internal
        }
        components.path = request.path
        components.queryItems = request.query.map { item in
            URLQueryItem(name: item.key, value: item.value.description)
        }
        guard let resourceURL = components.url else {
            logger.error("Unable to encode request URL components")
            throw HttpConnectorFailure.internal
        }
        var sessionRequest = URLRequest(url: resourceURL)
        sessionRequest.httpMethod = request.method.rawValue.uppercased()
        if let encodedBody = try encodedRequestBody(request) {
            sessionRequest.httpBody = encodedBody
        }
        defaultHeaders(for: request).forEach { field, value in
            sessionRequest.setValue(value, forHTTPHeaderField: field)
        }
        request.headers.forEach { field, value in
            sessionRequest.setValue(value, forHTTPHeaderField: field)
        }
        return sessionRequest
    }

    // MARK: - Private Properties

    private let configuration: HttpConnectorRequestMapperConfiguration
    private let encoder: JSONEncoder
    private let deviceMetadataProvider: DeviceMetadataProvider
    private let logger: POLogger

    // MARK: - Request Body Encoding

    private func encodedRequestBody(_ request: HttpConnectorRequest<some Decodable>) throws -> Data? {
        let decoratedBody: Encodable?
        if request.includesDeviceMetadata {
            let metadata = deviceMetadataProvider.deviceMetadata
            decoratedBody = DecoratedBody(body: request.body, deviceMetadata: metadata)
        } else {
            decoratedBody = request.body
        }
        guard let decoratedBody else {
            return nil
        }
        do {
            return try encoder.encode(decoratedBody)
        } catch {
            logger.error("Did fail to encode request body: '\(error)'")
            throw HttpConnectorFailure.coding(error)
        }
    }

    // MARK: - Request Headers

    private func authorization(request: HttpConnectorRequest<some Decodable>) -> String {
        var value = configuration.projectId + ":"
        if request.requiresPrivateKey {
            if let privateKey = configuration.privateKey {
                value += privateKey
            } else {
                preconditionFailure("Private key is required by '\(request)' request but not set")
            }
        }
        return "Basic " + Data(value.utf8).base64EncodedString()
    }

    private func defaultHeaders(for request: HttpConnectorRequest<some Decodable>) -> [String: String] {
        let deviceMetadata = deviceMetadataProvider.deviceMetadata
        let headers = [
            "Idempotency-Key": request.id,
            "User-Agent": userAgent(deviceMetadata: deviceMetadata),
            "Accept-Language": Strings.preferredLocalization,
            "Content-Type": "application/json",
            "Authorization": authorization(request: request),
            "Installation-Id": deviceMetadata.installationId,
            "Device-Id": deviceMetadata.id,
            "Device-System-Name": deviceMetadata.channel,
            "Device-System-Version": deviceMetadata.systemVersion,
            "Product-Version": configuration.version,
            "Host-Application-Version": configuration.appVersion
        ]
        return headers.compactMapValues { $0 }
    }

    private func userAgent(deviceMetadata: DeviceMetadata) -> String {
        let components = [
            deviceMetadata.channel,
            deviceMetadata.systemVersion + " ProcessOut iOS-Bindings",
            configuration.version
        ]
        return components.joined(separator: "/")
    }
}

/// Helps avoid using `JSONSerialization` to encode additional device metadata in request body.
private struct DecoratedBody: Encodable {

    /// Primary request body.
    let body: Encodable?

    /// Device metadata.
    let deviceMetadata: DeviceMetadata

    func encode(to encoder: Encoder) throws {
        // It allows to encode device metadata when there is no body,
        // because `encode` is called only if body is not nil.
        try body?.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deviceMetadata, forKey: .device)
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case device
    }
}
