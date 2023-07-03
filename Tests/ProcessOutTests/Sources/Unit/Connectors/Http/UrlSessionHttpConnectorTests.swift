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

    func test_execute_whenRequestMapperFails_failsOnMainThread() {
        // Given
        requestMapper.urlRequestFromClosure = {
            throw HttpConnectorFailure.internal
        }
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: defaultRequest) { result in
            // Then
            if case .success = result {
                XCTFail("Unexpected success")
            }
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_execute_whenRequestMapperFailsWithHttpConnectorFailure_failsWithSameFailure() {
        // Given
        let codingError = NSError(domain: "", code: 1234)
        requestMapper.urlRequestFromClosure = {
            throw HttpConnectorFailure.coding(codingError)
        }
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: defaultRequest) { result in
            // Then
            switch result {
            case let .failure(.coding(error)):
                XCTAssertEqual(error as NSError, codingError)
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_execute_whenRequestMapperFailsWithNonHttpConnectorFailure_completesWithInternalFailure() {
        // Given
        requestMapper.urlRequestFromClosure = {
            throw NSError(domain: "", code: 1)
        }
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: defaultRequest) { result in
            // Then
            switch result {
            case .failure(.internal):
                break
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    // MARK: - URLSession

    func test_execute_whenUrlSessionTaskFails_fails() {
        // Given
        MockUrlProtocol.register(path: ".*") { _ in
            throw URLError(.notConnectedToInternet)
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: defaultRequest) { result in
            // Then
            switch result {
            case .failure(.networkUnreachable):
                break
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_execute_whenUrlSessionTaskCompletesWithUnsupportedUrlResponse_fails() {
        // Given
        MockUrlProtocol.register(path: ".*") { _ in
            (URLResponse(), Data())
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: defaultRequest) { result in
            // Then
            switch result {
            case .failure(.internal):
                break
            default:
                XCTFail("Expected internal failure")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_execute_whenResponseSuccessIsInvalid_failsWithCodingFailure() {
        // Given
        MockUrlProtocol.register(path: ".*") { response in
            try MockUrlProtocolResponseBuilder()
                .with(url: response.url)
                .with(content: #"{"success":"true"}"#) // value is string instead of boolean
                .build()
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: defaultRequest) { result in
            // Then
            switch result {
            case .failure(.coding):
                break
            default:
                XCTFail("Expected coding failure")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_execute_whenUnsuccessfulResponseDoesntHaveErrorDetails_failsWithCodingFailure() {
        // Given
        MockUrlProtocol.register(path: ".*") { response in
            try MockUrlProtocolResponseBuilder()
                .with(url: response.url)
                .with(statusCode: 500)
                .with(content: #"{"success":false}"#)
                .build()
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: defaultRequest) { result in
            // Then
            switch result {
            case .failure(.coding):
                break
            default:
                XCTFail("Expected coding failure")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_execute_whenSuccessfulResponseDoesntHaveValue_failsWithCodingFailure() {
        // Given
        MockUrlProtocol.register(path: ".*") { response in
            try MockUrlProtocolResponseBuilder()
                .with(url: response.url)
                .with(content: #"{"success":true}"#)
                .build()
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest
        let request = HttpConnectorRequest<Int>.get(path: "")
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: request) { result in
            // Then
            switch result {
            case .failure(.coding):
                break
            default:
                XCTFail("Expected coding failure")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Unverified

    func test_whenUnsuccessfulResponseHaveErrorDetails_completesWithServerFailure() {
        // Given
        MockUrlProtocol.register(path: ".*") { response in
            try MockUrlProtocolResponseBuilder()
                .with(url: response.url)
                .with(statusCode: 404)
                .with(content: #"{"success":false, "errorType": "card.invalid-number"}"#)
                .build()
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: defaultRequest) { result in
            // Then
            switch result {
            case let .failure(.server(serverError, statusCode)):
                XCTAssertEqual(serverError.errorType, "card.invalid-number")
                XCTAssertEqual(statusCode, 404)
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_whenSuccessfulResponseHasValidValue_completesWithValue() {
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
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: request) { result in
            // Then
            switch result {
            case let .success(value):
                XCTAssertEqual(value.source, "test")
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_execute_whenCancelled_completesWithCancellationError() {
        // Given
        MockUrlProtocol.register(path: ".*") { _ in
            try await Task.sleep(for: .seconds(2))
            throw URLError(.timedOut)
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest
        let expectation = XCTestExpectation()

        // When
        let cancellable = sut.execute(request: defaultRequest) { result in
            // Then
            switch result {
            case .failure(.cancelled):
                break
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            cancellable.cancel()
        }
        wait(for: [expectation], timeout: 1)
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
