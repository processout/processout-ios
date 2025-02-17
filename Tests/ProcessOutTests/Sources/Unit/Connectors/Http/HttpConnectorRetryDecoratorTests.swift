//
//  HttpConnectorRetryDecoratorTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 12.11.2024.
//

import Foundation
import Testing
@testable @_spi(PO) import ProcessOut

struct HttpConnectorRetryDecoratorTests {

    init() {
        mock = MockHttpConnector()
        sut = HttpConnectorRetryDecorator(
            connector: mock, retryStrategy: .init(function: .linear(interval: 0), maximumRetries: 1)
        )
    }

    @Test(
        arguments: [
            HttpConnectorRequest<VoidCodable>.post(path: ""), .delete(path: ""), .put(path: "")
        ]
    )
    func execute_whenRequestMethodIsPostOrDeleteOrPut_addsSameIdempotencyKeyHeader(
        request: HttpConnectorRequest<VoidCodable>
    ) async throws {
        // Given
        var previousIdempotencyKey: String?

        // Then
        mock.executeFromClosure = { request throws(HttpConnectorFailure) in
            let request = request as! HttpConnectorRequest<VoidCodable> // swiftlint:disable:this force_cast
            let idempotencyKey = request.headers["Idempotency-Key"]
            #expect(idempotencyKey != nil)
            if previousIdempotencyKey != nil {
                #expect(previousIdempotencyKey == idempotencyKey)
            }
            previousIdempotencyKey = idempotencyKey
            throw HttpConnectorFailure(code: .networkUnreachable, underlyingError: nil)
        }

        // When
        _ = try? await sut.execute(request: request)

        // Then
        #expect(previousIdempotencyKey != nil && mock.executeCallsCount == 2)
    }

    @Test
    func execute_whenRequestMethodIsGet_doesntAddIdempotencyKeyHeader() async throws {
        // Given
        let requests = [
            HttpConnectorRequest<VoidCodable>.get(path: "")
        ]

        // Then
        mock.executeFromClosure = { request throws(HttpConnectorFailure) in
            // Then
            let request = request as! HttpConnectorRequest<VoidCodable> // swiftlint:disable:this force_cast
            #expect(request.headers["Idempotency-Key"] == nil)
            throw HttpConnectorFailure(code: .networkUnreachable, underlyingError: nil)
        }

        // When
        for request in requests {
            _ = try? await sut.execute(request: request)
        }
    }

    // MARK: - Private Properties

    private let mock: MockHttpConnector
    private let sut: any HttpConnector<HttpConnectorFailure>
}
