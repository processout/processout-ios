//
//  UrlSessionHttpConnectorTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2023.
//

import Foundation
import XCTest
@testable import ProcessOut

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
            logger: POLogger()
        )
    }

    override func tearDown() {
        super.tearDown()
        MockUrlProtocol.removeRegistrations()
    }

    // MARK: - Tests

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

    func test_execute_whenRequestMapperFailsWithError_completesWithInternalFailure() {
        // Given
        requestMapper.urlRequestFromClosure = {
            throw NSError(domain: "", code: 1)
        }
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: defaultRequest) { result in
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

    func test_execute_whenSessionFails_fails() {
        // Given
        MockUrlProtocol.register(path: ".*") { _ in
            throw URLError(.notConnectedToInternet)
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: defaultRequest) { result in
            if case .success = result {
                XCTFail("Expected failure")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_execute_whenSessionCompletesWithUnsupportedUrlResponse_fails() {
        // Given
        MockUrlProtocol.register(path: ".*") { _ in
            (URLResponse(), Data())
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: defaultRequest) { result in
            if case .success = result {
                XCTFail("Expected failure")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Unverified

    func test_execute_whenXXX_fails() { // whenSuccessFieldIsInvalid_fails
        // Given
        MockUrlProtocol.register(path: ".*") { _ in
            let response = HTTPURLResponse(
                url: Constants.baseUrl, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            // success value is string instead of boolean
            return (response, Data(#"{"success":"true"}"#.utf8))
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: defaultRequest) { result in
            if case .success = result {
                XCTFail("Expected failure")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_execute_whenYYY_fails() { // whenSuccessIsFalseAndResponseDoesntContainError_fails
        // Given
        MockUrlProtocol.register(path: ".*") { _ in
            let response = HTTPURLResponse(
                url: Constants.baseUrl, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, Data(#"{"success":false}"#.utf8))
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: defaultRequest) { result in
            if case .success = result {
                XCTFail("Expected failure")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_execute_whenZZZ_fails() { // whenSuccessIsTrueAndResponseDoesntContainValue_fails
        // Given
        MockUrlProtocol.register(path: ".*") { _ in
            let response = HTTPURLResponse(
                url: Constants.baseUrl, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, Data(#"{"success":true}"#.utf8))
        }
        requestMapper.urlRequestFromClosure = defaultUrlRequest
        let request = HttpConnectorRequest<Int>.get(path: "")
        let expectation = XCTestExpectation()

        // When
        _ = sut.execute(request: request) { result in
            if case .success = result {
                XCTFail("Expected failure")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_execute_whenWWW_fails() { // whenSuccessIsFalseAndResponseIsValid_completesWithServerFailure
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

    // whenSuccessIsTrueAndResponseIsValid_completesWithResponse

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
