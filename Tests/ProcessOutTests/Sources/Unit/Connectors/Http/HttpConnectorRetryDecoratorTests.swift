//
//  HttpConnectorRetryDecoratorTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 12.11.2024.
//

import Foundation
import XCTest
@testable @_spi(PO) import ProcessOut

final class HttpConnectorRetryDecoratorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        mock = MockHttpConnector()
        sut = HttpConnectorRetryDecorator(
            connector: mock, retryStrategy: .init(function: .linear(interval: 0), maximumRetries: 1)
        )
    }

    func test_execute_whenRequestMethodIsPost_addsSameIdempotencyKeyHeader() async throws {
        // Given
        let request = HttpConnectorRequest<VoidCodable>.post(path: "")
        var previousIdempotencyKey: String?

        // Then
        mock.executeFromClosure = { request in
            let request = request as! HttpConnectorRequest<VoidCodable> // swiftlint:disable:this force_cast
            let idempotencyKey = request.headers["Idempotency-Key"]
            XCTAssertNotNil(idempotencyKey)
            if previousIdempotencyKey != nil {
                XCTAssertEqual(previousIdempotencyKey, idempotencyKey)
            }
            previousIdempotencyKey = idempotencyKey
            throw HttpConnectorFailure(code: .networkUnreachable, underlyingError: nil)
        }

        // When
        _ = try? await sut.execute(request: request)

        // Then
        XCTAssertNotNil(previousIdempotencyKey)
        XCTAssertEqual(mock.executeCallsCount, 2)
    }

    func test_execute_whenRequestMethodIsGetOrPut_doesntAddIdempotencyKeyHeader() async throws {
        // Given
        let requests = [
            HttpConnectorRequest<VoidCodable>.get(path: ""),
            HttpConnectorRequest<VoidCodable>.put(path: "")
        ]

        // Then
        mock.executeFromClosure = { request in
            // Then
            let request = request as! HttpConnectorRequest<VoidCodable> // swiftlint:disable:this force_cast
            let idempotencyKey = request.headers["Idempotency-Key"]
            XCTAssertNil(idempotencyKey)
            throw HttpConnectorFailure(code: .networkUnreachable, underlyingError: nil)
        }

        // When
        for request in requests {
            _ = try? await sut.execute(request: request)
        }
    }

    // MARK: - Private Properties

    private var mock: MockHttpConnector!
    private var sut: HttpConnector!
}
