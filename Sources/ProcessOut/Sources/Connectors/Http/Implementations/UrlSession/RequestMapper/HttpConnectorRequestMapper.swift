//
//  HttpConnectorRequestMapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2023.
//

import Foundation

protocol HttpConnectorRequestMapper {

    /// Transforms given `HttpConnectorRequest` to `URLRequest`.
    func urlRequest(from request: HttpConnectorRequest<some Decodable>) async throws -> URLRequest
}
