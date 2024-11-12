//
//  HttpConnectorRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation

struct HttpConnectorRequest<Value: Decodable & Sendable>: Sendable {

    enum Method: String {
        case get, put, post
    }

    typealias Body = Sendable & Encodable

    /// Request identifier.
    let id: String

    /// Method type.
    let method: Method

    /// Method path.
    let path: String

    /// Query items.
    let query: [String: String]

    /// Parameters.
    let body: Body?

    /// Custom headers.
    let headers: [String: String]

    /// Lets us inject device metadata into requests. If you set this property to `true` make sure that request
    /// body is valid key pair object or `nil`.
    let includesDeviceMetadata: Bool

    /// Indicates whether private key is required to execute request. Default value is `false`.
    let requiresPrivateKey: Bool

    /// Expected value type.
    let expectedValueType: Value.Type = Value.self
}

extension HttpConnectorRequest {

    static func get(
        path: String,
        query: [String: CustomStringConvertible] = [:],
        headers: [String: String] = [:],
        requiresPrivateKey: Bool = false
    ) -> Self {
        .init(
            id: UUID().uuidString,
            method: .get,
            path: path,
            query: query.mapValues(\.description),
            body: nil,
            headers: headers,
            includesDeviceMetadata: false,
            requiresPrivateKey: requiresPrivateKey
        )
    }

    static func post(
        path: String,
        body: Body? = nil,
        headers: [String: String] = [:],
        includesDeviceMetadata: Bool = false,
        requiresPrivateKey: Bool = false
    ) -> Self {
        .init(
            id: UUID().uuidString,
            method: .post,
            path: path,
            query: [:],
            body: body,
            headers: headers,
            includesDeviceMetadata: includesDeviceMetadata,
            requiresPrivateKey: requiresPrivateKey
        )
    }

    static func put(
        path: String,
        body: Body? = nil,
        headers: [String: String] = [:],
        includesDeviceMetadata: Bool = false,
        requiresPrivateKey: Bool = false
    ) -> Self {
        .init(
            id: UUID().uuidString,
            method: .put,
            path: path,
            query: [:],
            body: body,
            headers: headers,
            includesDeviceMetadata: includesDeviceMetadata,
            requiresPrivateKey: requiresPrivateKey
        )
    }
}
