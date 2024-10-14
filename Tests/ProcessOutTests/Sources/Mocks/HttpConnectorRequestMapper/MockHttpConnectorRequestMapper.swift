//
//  StubHttpConnectorRequestMapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.04.2023.
//

import Foundation
@testable @_spi(PO) import ProcessOut

final class MockHttpConnectorRequestMapper: HttpConnectorRequestMapper {

    var urlRequestFromCallsCount: Int {
        lock.withLock { _urlRequestFromCallsCount }
    }

    var urlRequestFromClosure: (() throws -> URLRequest)! {
        get { lock.withLock { _urlRequestFromClosure } }
        set { lock.withLock { _urlRequestFromClosure = newValue } }
    }

    func urlRequest(from request: HttpConnectorRequest<some Decodable>) throws -> URLRequest {
        try lock.withLock {
            _urlRequestFromCallsCount += 1
            return try urlRequestFromClosure()
        }
    }

    func replace(configuration: HttpConnectorRequestMapperConfiguration) {
        // Not implemented
    }

    // MARK: - Private Properties

    private let lock = POUnfairlyLocked()

    private nonisolated(unsafe) var _urlRequestFromCallsCount = 0
    private nonisolated(unsafe) var _urlRequestFromClosure: (() throws -> URLRequest)!
}
