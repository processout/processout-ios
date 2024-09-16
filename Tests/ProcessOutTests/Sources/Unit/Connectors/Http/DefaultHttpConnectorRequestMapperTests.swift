//
//  DefaultHttpConnectorRequestMapperTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2023.
//

import Foundation
import XCTest
@testable @_spi(PO) import ProcessOut

final class DefaultHttpConnectorRequestMapperTests: XCTestCase {

    // MARK: - Request Path

    func test_urlRequest_whenPathIsInvalid_fails() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "|")

        // Then
        await assertThrowsError(try await sut.urlRequest(from: request))
    }

    func test_urlRequest_whenPathIsValid_succeeds() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "/test/path")

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        XCTAssertEqual(urlRequest.url?.path(), request.path)
    }

    // MARK: - Request Body

    func test_urlRequest_whenBodyIsSet_encodesBody() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.post(path: "", body: "body")

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        XCTAssertEqual(urlRequest.httpBody, Data(#""body""#.utf8))
    }

    func test_urlRequest_whenIncludesDeviceMetadataButBodyIsNotSet_encodesBody() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.post(path: "", includesDeviceMetadata: true)

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        // swiftlint:disable:next line_length
        let expectedBody = #"{"device":{"appLanguage":"en","appScreenHeight":2,"appScreenWidth":1,"appTimeZoneOffset":3,"channel":"test"}}"#
        XCTAssertEqual(urlRequest.httpBody, Data(expectedBody.utf8))
    }

    func test_urlRequest_whenIncludesDeviceMetadataAndBodyIsSet_encodesBody() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.post(
            path: "", body: ["key": "value"], includesDeviceMetadata: true
        )

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        // swiftlint:disable:next line_length
        let expectedBody = #"{"device":{"appLanguage":"en","appScreenHeight":2,"appScreenWidth":1,"appTimeZoneOffset":3,"channel":"test"},"key":"value"}"#
        XCTAssertEqual(urlRequest.httpBody, Data(expectedBody.utf8))
    }

    func test_urlRequest_whenBodyIsNotSet_returnsRequestWithoutBody() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        XCTAssertNil(urlRequest.httpBody)
    }

    func test_urlRequest_whenBodyIsInvalid_fails() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.post(path: "", body: Float.infinity)

        // Then
        await assertThrowsError(try await sut.urlRequest(from: request))
    }

    // MARK: - Request Query

    func test_urlRequest_whenQueryIsSet_succeeds() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "", query: ["key": "value"])

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        XCTAssertEqual(urlRequest.url?.query(), "key=value")
    }

    // MARK: - Request Headers

    func test_urlRequest_addsUserAgent() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        let userAgent = urlRequest.value(forHTTPHeaderField: "user-agent")
        let userAgentRegex = /^iOS\/4 ProcessOut iOS-Bindings\/1\.2\.3$/
        XCTAssertNotNil(userAgent?.firstMatch(of: userAgentRegex))
    }

    func test_urlRequest_whenPrivateKeyIsNotRequired_addsAuthorization() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        let authorization = urlRequest.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authorization, "Basic PElEPjo8S0VZPg==")
    }

    func test_urlRequest_whenPrivateKeyIsRequired_addsAuthorization() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "", requiresPrivateKey: true)

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        let authorization = urlRequest.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authorization, "Basic PElEPjo8S0VZPg==")
    }

    func test_urlRequest_addsDefaultHeaders() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        let expectedHeaders = ["Idempotency-Key", "User-Agent", "Accept-Language", "Content-Type", "Authorization"]
        for header in expectedHeaders {
            XCTAssertNotNil(urlRequest.value(forHTTPHeaderField: header))
        }
    }

    func test_urlRequest_addsValidIdempotencyKeyHeader() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        let idempotencyKey = urlRequest.value(forHTTPHeaderField: "Idempotency-Key")
        XCTAssertEqual(idempotencyKey, request.id)
    }

    func test_urlRequest_addsJsonContentTypeHeader() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        let idempotencyKey = urlRequest.value(forHTTPHeaderField: "Content-Type")
        XCTAssertEqual(idempotencyKey, "application/json")
    }

    func test_urlRequest_whenRequestHeaderIsSet_overridesDefaultHeader() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "", headers: ["Content-Type": "test"])

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "test")
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let baseUrl = URL(string: "https://example.com")!
    }

    // MARK: - Private Methods

    private func createMapper(
        configuration: HttpConnectorRequestMapperConfiguration
    ) -> DefaultHttpConnectorRequestMapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let mapper = DefaultHttpConnectorRequestMapper(
            configuration: { configuration },
            encoder: encoder,
            deviceMetadataProvider: StubDeviceMetadataProvider(),
            logger: .stub
        )
        return mapper
    }

    private var defaultConfiguration: HttpConnectorRequestMapperConfiguration {
        .init(baseUrl: Constants.baseUrl, projectId: "<ID>", privateKey: "<KEY>", sessionId: "<SID>", version: "1.2.3")
    }
}
