//
//  HttpConnectorRequestMapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2023.
//

import Foundation
import UIKit.UIDevice

final class HttpConnectorRequestMapper: HttpConnectorRequestMapperType {

    init(
        configuration: HttpConnectorRequestMapperConfiguration,
        encoder: JSONEncoder,
        deviceMetadataProvider: DeviceMetadataProviderType,
        logger: POLogger
    ) {
        self.configuration = configuration
        self.encoder = encoder
        self.deviceMetadataProvider = deviceMetadataProvider
        self.logger = logger
    }

    func urlRequest(from request: HttpConnectorRequest<some Decodable>) throws -> URLRequest {
        guard var components = URLComponents(url: configuration.baseUrl, resolvingAgainstBaseURL: true) else {
            throw HttpConnectorFailure.internal
        }
        components.path = request.path
        components.queryItems = request.query.map { item in
            URLQueryItem(name: item.key, value: item.value.description)
        }
        guard let resourceURL = components.url else {
            throw HttpConnectorFailure.internal
        }
        var sessionRequest = URLRequest(url: resourceURL)
        sessionRequest.httpMethod = request.method.rawValue.uppercased()
        if let encodedBody = try encodedRequestBody(request) {
            sessionRequest.httpBody = encodedBody
        }
        let defaultHeaders = [
            "Idempotency-Key": request.id,
            "User-Agent": userAgent,
            "Accept-Language": Strings.preferredLocalization,
            "Content-Type": "application/json",
            "Authorization": try authorization(request: request)
        ]
        defaultHeaders.forEach { field, value in
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
    private let deviceMetadataProvider: DeviceMetadataProviderType
    private let logger: POLogger

    private var userAgent: String {
        let components = [
            UIDevice.current.systemName,
            "Version",
            UIDevice.current.systemVersion,
            "ProcessOut iOS-Bindings",
            configuration.version
        ]
        return components.joined(separator: "/")
    }

    // MARK: - Private Methods

    private func encodedRequestBody(_ request: HttpConnectorRequest<some Decodable>) throws -> Data? {
        if var body = request.body {
            if request.includesDeviceMetadata {
                let metadata = deviceMetadataProvider.deviceMetadata
                body = POAnyEncodable(DecoratedBody(body: body, deviceMetadata: metadata))
            }
            do {
                return try encoder.encode(body)
            } catch {
                throw HttpConnectorFailure.coding(error)
            }
        } else if request.includesDeviceMetadata {
            logger.error("Can't include metadata in a bodiless request")
            throw HttpConnectorFailure.internal
        }
        return nil
    }

    private func authorization(request: HttpConnectorRequest<some Decodable>) throws -> String {
        var value = configuration.projectId + ":"
        if request.requiresPrivateKey {
            if let privateKey = configuration.privateKey {
                value += privateKey
            } else {
                logger.info("Private key is required by '\(request.id)' request but not set")
                throw HttpConnectorFailure.internal
            }
        }
        return "Basic " + Data(value.utf8).base64EncodedString()
    }
}

/// Helps avoid using `JSONSerialization` to encode additional device metadata in request body.
private struct DecoratedBody: Encodable {

    /// Primary request body.
    let body: POAnyEncodable

    /// Device metadata.
    let deviceMetadata: DeviceMetadata

    func encode(to encoder: Encoder) throws {
        try body.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deviceMetadata, forKey: .device)
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case device
    }
}
