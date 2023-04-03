//
//  HttpConnectorRequestMapperType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2023.
//

import Foundation

protocol HttpConnectorRequestMapperType {

    /// Transforms given `HttpConnectorRequest` to `URLRequest`.
    func urlRequest(from request: HttpConnectorRequest<some Decodable>) throws -> URLRequest
}
