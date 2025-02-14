//
//  HttpConnectorRequestMapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2023.
//

import Foundation

protocol HttpConnectorRequestMapper<Failure>: Sendable {

    associatedtype Failure: Error

    /// Transforms given `HttpConnectorRequest` to `URLRequest`.
    func urlRequest(from request: HttpConnectorRequest<some Decodable>) async throws(Failure) -> URLRequest

    /// Replaces current configuration.
    func replace(configuration: HttpConnectorConfiguration)
}
