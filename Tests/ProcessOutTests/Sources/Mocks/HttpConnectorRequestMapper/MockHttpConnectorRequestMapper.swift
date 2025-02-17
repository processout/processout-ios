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

    var urlRequestFromClosure: (() throws(Failure) -> URLRequest)! {
        get { lock.withLock { _urlRequestFromClosure } }
        set { lock.withLock { _urlRequestFromClosure = newValue } }
    }

    // MARK: - HttpConnectorRequestMapper

    func urlRequest(from request: HttpConnectorRequest<some Decodable>) throws(Failure) -> URLRequest {
        try lock.withLock { () throws(Failure) in
            _urlRequestFromCallsCount += 1
            return try _urlRequestFromClosure()
        }
    }

    func replace(configuration: HttpConnectorConfiguration) {
        // Not implemented
    }

    // MARK: - Private Properties

    private let lock = POUnfairlyLocked()

    private nonisolated(unsafe) var _urlRequestFromCallsCount = 0
    private nonisolated(unsafe) var _urlRequestFromClosure: (() throws(Failure) -> URLRequest)!
}
