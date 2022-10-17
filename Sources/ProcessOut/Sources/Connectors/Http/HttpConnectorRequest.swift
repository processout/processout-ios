//
//  HttpConnectorRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation

struct HttpConnectorRequest<Value: Decodable> {

    enum Method: String {
        case get, put, post
    }

    /// Request identifier.
    let id: String

    /// Method type.
    let method: Method

    /// Method path.
    let path: String

    /// Query items.
    let query: [String: CustomStringConvertible]

    /// Parameters.
    let body: AnyEncodable?

    /// Custom headers.
    let headers: [String: String]

    /// Expected value type.
    let expectedValueType: Value.Type = Value.self
}

extension HttpConnectorRequest {

    static func get(
        path: String, query: [String: CustomStringConvertible] = [:], headers: [String: String] = [:]
    ) -> Self {
        .init(id: UUID().uuidString, method: .get, path: path, query: query, body: nil, headers: headers)
    }

    static func post<E: Encodable>(path: String, body: E?, headers: [String: String] = [:]) -> Self {
        .init(id: UUID().uuidString, method: .post, path: path, query: [:], body: AnyEncodable(body), headers: headers)
    }

    static func put<E: Encodable>(path: String, body: E?, headers: [String: String] = [:]) -> Self {
        .init(id: UUID().uuidString, method: .put, path: path, query: [:], body: AnyEncodable(body), headers: headers)
    }
}
