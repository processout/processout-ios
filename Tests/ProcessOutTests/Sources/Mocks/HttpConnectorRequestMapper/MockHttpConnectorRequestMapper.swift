//
//  StubHttpConnectorRequestMapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.04.2023.
//

import Foundation
@testable import ProcessOut

final class MockHttpConnectorRequestMapper: HttpConnectorRequestMapper {

    var urlRequestFromCallsCount = 0
    var urlRequestFromClosure: (() throws -> URLRequest)!

    func configure(configuration: HttpConnectorConfiguration) {
        // Ignored
    }

    func urlRequest(from request: HttpConnectorRequest<some Decodable>) throws -> URLRequest {
        urlRequestFromCallsCount += 1
        return try urlRequestFromClosure()
    }
}
