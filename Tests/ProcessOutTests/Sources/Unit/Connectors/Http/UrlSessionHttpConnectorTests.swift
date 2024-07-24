//
//  UrlSessionHttpConnectorTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2023.
//

import Foundation
import XCTest
@testable @_spi(PO) import ProcessOut

final class UrlSessionHttpConnectorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockUrlProtocol.self]
        requestMapper = MockHttpConnectorRequestMapper()
        sut = UrlSessionHttpConnector(
            sessionConfiguration: sessionConfiguration,
            requestMapper: requestMapper,
            decoder: JSONDecoder(),
            logger: .stub
        )
    }

    override func tearDown() {
        super.tearDown()
        MockUrlProtocol.removeRegistrations()
    }

    // MARK: - Request Mapper

    func test_execute_whenRequestMapperFailsWithHttpConnectorFailure_failsWithSameFailure() async throws {
        // Given
        let codingError = NSError(domain: "", code: 1234)
        requestMapper.urlRequestFromClosure = {
            throw HttpConnectorFailure.encoding(codingError)
        }

        // When
        let error = await assertThrowsError(
            try await sut.execute(request: defaultRequest)
        )

        // Then
        if let failure = error as? HttpConnectorFailure, case .encoding(let encodingError) = failure {
            XCTAssertEqual(encodingError as NSError, codingError)
            return
        }
        XCTFail("Unexpected result")
    }

    // MARK: - URLSession

    func test_execute_whenUrlSessionTaskFails_fails() async {
        // Given
        MockUrlProtocol.register(path: ".*") { _ in
            throw URLError(.notConnectedToInternet)
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest

        // When
        let error = await assertThrowsError(
            try await sut.execute(request: defaultRequest)
        )

        // Then
        if let failure = error as? HttpConnectorFailure, case .networkUnreachable = failure {
            return
        }
        XCTFail("Unexpected result")
    }

    func test_execute_whenUrlSessionTaskCompletesWithUnsupportedUrlResponse_fails() async {
        // Given
        MockUrlProtocol.register(path: ".*") { _ in
            (URLResponse(), Data())
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest

        // When
        let error = await assertThrowsError(
            try await sut.execute(request: defaultRequest)
        )

        // Then
        if let failure = error as? HttpConnectorFailure, case .internal = failure {
            return
        }
        XCTFail("Expected internal failure")
    }

    func test_execute_whenResponseSuccessIsInvalid_failsWithCodingFailure() async {
        // Given
        MockUrlProtocol.register(path: ".*") { response in
            try MockUrlProtocolResponseBuilder()
                .with(url: response.url)
                .with(content: #"{"success":"true"}"#) // value is string instead of boolean
                .build()
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest

        // When
        let error = await assertThrowsError(
            try await sut.execute(request: defaultRequest)
        )

        // Then
        if case let failure = error as? HttpConnectorFailure, case .decoding = failure {
            return
        }
        XCTFail("Unexpected result")
    }

    func test_execute_whenUnsuccessfulResponseDoesntHaveErrorDetails_failsWithCodingFailure() async {
        // Given
        MockUrlProtocol.register(path: ".*") { response in
            try MockUrlProtocolResponseBuilder()
                .with(url: response.url)
                .with(statusCode: 500)
                .with(content: #"{"success":false}"#)
                .build()
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest

        // When
        let error = await assertThrowsError(
            try await sut.execute(request: defaultRequest)
        )

        // Then
        if case let failure = error as? HttpConnectorFailure, case .decoding = failure {
            return
        }
        XCTFail("Unexpected result")
    }

    func test_execute_whenSuccessfulResponseDoesntHaveValue_failsWithCodingFailure() async {
        // Given
        MockUrlProtocol.register(path: ".*") { response in
            try MockUrlProtocolResponseBuilder()
                .with(url: response.url)
                .with(content: #"{"success":true}"#)
                .build()
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest
        let request = HttpConnectorRequest<Int>.get(path: "")

        // When
        let error = await assertThrowsError(
            try await sut.execute(request: request)
        )

        // Then
        if case let failure = error as? HttpConnectorFailure, case .decoding = failure {
            return
        }
        XCTFail("Unexpected result")
    }

    func test_whenUnsuccessfulResponseHaveErrorDetails_completesWithServerFailure() async {
        // Given
        MockUrlProtocol.register(path: ".*") { response in
            try MockUrlProtocolResponseBuilder()
                .with(url: response.url)
                .with(statusCode: 404)
                .with(content: #"{"success":false, "errorType": "card.invalid-number"}"#)
                .build()
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest

        // When
        let error = await assertThrowsError(
            try await sut.execute(request: defaultRequest)
        )

        // Then
        if let failure = error as? HttpConnectorFailure, case let .server(serverError, statusCode) = failure {
            XCTAssertEqual(serverError.errorType, "card.invalid-number")
            XCTAssertEqual(statusCode, 404)
        } else {
            XCTFail("Unexpected result")
        }
    }

    func test_whenSuccessfulResponseHasValidValue_completesWithValue() async throws {
        struct Response: Decodable {
            let source: String
        }

        // Given
        MockUrlProtocol.register(path: ".*") { response in
            try MockUrlProtocolResponseBuilder()
                .with(url: response.url)
                .with(content: #"{"success":true, "source": "test"}"#)
                .build()
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest
        let request = HttpConnectorRequest<Response>.get(path: "")

        // When
        let value = try await sut.execute(request: request) as Response

        // Then
        XCTAssertEqual(value.source, "test")
    }

    func test_execute_whenCancelled_completesWithCancellationError() async throws {
        // Given
        MockUrlProtocol.register(path: ".*") { _ in
            try await Task.sleep(for: .seconds(2))
            throw URLError(.timedOut)
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest

        // When
        let task = Task {
            _ = try await sut.execute(request: defaultRequest)
        }
        DispatchQueue.main.async {
            task.cancel()
        }

        // Then
        let error = await assertThrowsError(try await task.value)
        if case let failure = error as? HttpConnectorFailure, case .cancelled = failure {
            return
        }
        XCTFail("Unexpected result")
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let baseUrl = URL(string: "https://example.com")!
    }

    // MARK: - Private Properties

    private var requestMapper: MockHttpConnectorRequestMapper!
    private var sut: UrlSessionHttpConnector!

    // MARK: - Private Methods

    private var defaultRequest: HttpConnectorRequest<some Decodable> {
        HttpConnectorRequest<VoidCodable>.get(path: "")
    }

    private func defaultUrlRequest() -> URLRequest {
        URLRequest(url: Constants.baseUrl)
    }
}
