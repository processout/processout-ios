//
//  UrlSessionHttpConnectorTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 03.04.2023.
//

import Foundation
import Testing
@testable @_spi(PO) import ProcessOut

@Suite(.serialized)
final class UrlSessionHttpConnectorTests {

    init() {
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

    deinit {
        MockUrlProtocol.removeRegistrations()
    }

    // MARK: - Request Mapper

    @Test
    func execute_whenRequestMapperFailsWithHttpConnectorFailure_failsWithSameFailure() async throws {
        // Given
        let codingError = NSError(domain: "", code: 1234)
        requestMapper.urlRequestFromClosure = { () throws(HttpConnectorFailure) in
            throw HttpConnectorFailure(code: .encoding, underlyingError: codingError)
        }

        // When
        try await withKnownIssue {
            _ = try await sut.execute(request: Self.defaultRequest)
        } matching: { issue in
            if let failure = issue.error as? HttpConnectorFailure, case .encoding = failure.code {
                return failure.underlyingError as NSError? == codingError
            }
            return false
        }
    }

    // MARK: - URLSession

    @Test
    func execute_whenUrlSessionTaskFails_fails() async throws {
        // Given
        MockUrlProtocol.register(path: ".*") { _ in
            throw URLError(.notConnectedToInternet)
        }
        requestMapper.urlRequestFromClosure = {
            Self.defaultUrlRequest
        }

        // When
        try await withKnownIssue {
            _ = try await sut.execute(request: Self.defaultRequest)
        } matching: { issue in
            if let failure = issue.error as? HttpConnectorFailure, case .networkUnreachable = failure.code {
                return true
            }
            return false
        }
    }

    @Test
    func execute_whenUrlSessionTaskCompletesWithUnsupportedUrlResponse_fails() async throws {
        // Given
        MockUrlProtocol.register(path: ".*") { _ in
            (URLResponse(), Data())
        }
        requestMapper.urlRequestFromClosure = {
            Self.defaultUrlRequest
        }

        // When
        try await withKnownIssue {
            _ = try await sut.execute(request: Self.defaultRequest)
        } matching: { issue in
            if let failure = issue.error as? HttpConnectorFailure, case .internal = failure.code {
                return true
            }
            return false
        }
    }

    @Test
    func execute_whenResponseSuccessIsInvalid_failsWithCodingFailure() async throws {
        // Given
        MockUrlProtocol.register(path: ".*") { response in
            try MockUrlProtocolResponseBuilder()
                .with(url: response.url)
                .with(content: #"{"success":"true"}"#) // value is string instead of boolean
                .build()
        }
        requestMapper.urlRequestFromClosure = {
            Self.defaultUrlRequest
        }

        // When
        try await withKnownIssue {
            _ = try await sut.execute(request: Self.defaultRequest)
        } matching: { issue in
            if let failure = issue.error as? HttpConnectorFailure, case .decoding = failure.code {
                return true
            }
            return false
        }
    }

    @Test
    func execute_whenUnsuccessfulResponseDoesntHaveErrorDetails_failsWithCodingFailure() async throws {
        // Given
        MockUrlProtocol.register(path: ".*") { response in
            try MockUrlProtocolResponseBuilder()
                .with(url: response.url)
                .with(statusCode: 500)
                .with(content: #"{"success":false}"#)
                .build()
        }
        requestMapper.urlRequestFromClosure = {
            Self.defaultUrlRequest
        }

        // When
        try await withKnownIssue {
            _ = try await sut.execute(request: Self.defaultRequest)
        } matching: { issue in
            if let failure = issue.error as? HttpConnectorFailure, case .decoding = failure.code {
                return true
            }
            return false
        }
    }

    @Test
    func execute_whenSuccessfulResponseDoesntHaveValue_failsWithCodingFailure() async throws {
        // Given
        MockUrlProtocol.register(path: ".*") { response in
            try MockUrlProtocolResponseBuilder()
                .with(url: response.url)
                .with(content: #"{"success":true}"#)
                .build()
        }
        requestMapper.urlRequestFromClosure = {
            Self.defaultUrlRequest
        }
        let request = HttpConnectorRequest<Int>.get(path: "")

        // When
        try await withKnownIssue {
            _ = try await sut.execute(request: request)
        } matching: { issue in
            if let failure = issue.error as? HttpConnectorFailure, case .decoding = failure.code {
                return true
            }
            return false
        }
    }

    @Test
    func execute_whenUnsuccessfulResponseHaveErrorDetails_completesWithServerFailure() async throws {
        // Given
        MockUrlProtocol.register(path: ".*") { response in
            try MockUrlProtocolResponseBuilder()
                .with(url: response.url)
                .with(statusCode: 404)
                .with(content: #"{"success":false, "errorType": "card.invalid-number"}"#)
                .build()
        }
        requestMapper.urlRequestFromClosure = {
            Self.defaultUrlRequest
        }

        // When
        try await withKnownIssue {
            _ = try await sut.execute(request: Self.defaultRequest)
        } matching: { issue in
            if let failure = issue.error as? HttpConnectorFailure,
               case let .server(serverError, statusCode) = failure.code {
                return serverError.errorType == "card.invalid-number" && statusCode == 404
            }
            return false
        }
    }

    @Test
    func execute_whenSuccessfulResponseHasValidValue_completesWithValue() async throws {
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
        requestMapper.urlRequestFromClosure = {
            Self.defaultUrlRequest
        }
        let request = HttpConnectorRequest<Response>.get(path: "")

        // When
        let value = try await sut.execute(request: request) as Response

        // Then
        #expect(value.source == "test")
    }

    @Test
    func execute_whenCancelled_completesWithCancellationError() async throws {
        // Given
        MockUrlProtocol.register(path: ".*") { _ in
            try await Task.sleep(for: .seconds(2))
            throw URLError(.timedOut)
        }
        requestMapper.urlRequestFromClosure = {
            Self.defaultUrlRequest
        }

        // When
        let task = Task {
            _ = try await sut.execute(request: Self.defaultRequest)
        }
        DispatchQueue.main.async {
            task.cancel()
        }

        // Then
        try await withKnownIssue {
            try await task.value
        } matching: { issue in
            if let failure = issue.error as? HttpConnectorFailure, case .cancelled = failure.code {
                return true
            }
            return false
        }
    }

    // MARK: - Private Properties

    private let requestMapper: MockHttpConnectorRequestMapper
    private let sut: UrlSessionHttpConnector

    // MARK: - Private Methods

    private static var defaultRequest: HttpConnectorRequest<some Decodable> {
        HttpConnectorRequest<VoidCodable>.get(path: "")
    }

    private static var defaultUrlRequest: URLRequest {
        URLRequest(url: URL(string: "https://example.com")!)
    }
}
