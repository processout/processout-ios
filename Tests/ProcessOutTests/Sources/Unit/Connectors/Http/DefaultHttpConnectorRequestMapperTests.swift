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

    // MARK: - URL

    func test_urlRequest_whenBaseUrlIsMalformed_fails() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: URL(string: "http://example.com:-80")!,
            projectId: "",
            privateKey: nil,
            version: "",
            appVersion: nil
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // Then
        XCTAssertThrowsError(try sut.urlRequest(from: request))
    }

    // MARK: - Request Path

    func test_urlRequest_whenPathIsInvalid_fails() throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "|")

        // Then
        XCTAssertThrowsError(try sut.urlRequest(from: request))
    }

    func test_urlRequest_whenPathIsValid_succeeds() throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "/test/path")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        XCTAssertEqual(urlRequest.url?.path(), request.path)
    }

    // MARK: - Request Body

    func test_urlRequest_whenBodyIsSet_encodesBody() throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.post(path: "", body: "body")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        XCTAssertEqual(urlRequest.httpBody, Data(#""body""#.utf8))
    }

    func test_urlRequest_whenIncludesDeviceMetadataButBodyIsNotSet_encodesBody() throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.post(path: "", includesDeviceMetadata: true)

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        // swiftlint:disable:next line_length
        let expectedBody = #"{"device":{"appLanguage":"en","appScreenHeight":2,"appScreenWidth":1,"appTimeZoneOffset":3,"channel":"test"}}"#
        XCTAssertEqual(urlRequest.httpBody, Data(expectedBody.utf8))
    }

    func test_urlRequest_whenIncludesDeviceMetadataAndBodyIsSet_encodesBody() throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.post(
            path: "", body: ["key": "value"], includesDeviceMetadata: true
        )

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        // swiftlint:disable:next line_length
        let expectedBody = #"{"device":{"appLanguage":"en","appScreenHeight":2,"appScreenWidth":1,"appTimeZoneOffset":3,"channel":"test"},"key":"value"}"#
        XCTAssertEqual(urlRequest.httpBody, Data(expectedBody.utf8))
    }

    func test_urlRequest_whenBodyIsNotSet_returnsRequestWithoutBody() throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        XCTAssertNil(urlRequest.httpBody)
    }

    func test_urlRequest_whenBodyIsInvalid_fails() throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.post(path: "", body: Float.infinity)

        // Then
        XCTAssertThrowsError(try sut.urlRequest(from: request))
    }

    // MARK: - Request Query

    func test_urlRequest_whenQueryIsSet_succeeds() throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "", query: ["key": "value"])

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        XCTAssertEqual(urlRequest.url?.query(), "key=value")
    }

    // MARK: - Request Headers

    func test_urlRequest_addsUserAgent() throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        let userAgent = urlRequest.value(forHTTPHeaderField: "user-agent")
        let userAgentRegex = /^test\/Version\/.*\/ProcessOut iOS-Bindings\/1\.2\.3$/
        XCTAssertNotNil(userAgent?.firstMatch(of: userAgentRegex))
    }

    func test_urlRequest_whenPrivateKeyIsNotRequired_addsAuthorization() throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        let authorization = urlRequest.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authorization, "Basic PElEPjo=")
    }

    func test_urlRequest_whenPrivateKeyIsRequired_addsAuthorization() throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "", requiresPrivateKey: true)

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        let authorization = urlRequest.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authorization, "Basic PElEPjo8S0VZPg==")
    }

    func test_urlRequest_addsDefaultHeaders() throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        let expectedHeaders = ["Idempotency-Key", "User-Agent", "Accept-Language", "Content-Type", "Authorization"]
        for header in expectedHeaders {
            XCTAssertNotNil(urlRequest.value(forHTTPHeaderField: header))
        }
    }

    func test_urlRequest_addsValidIdempotencyKeyHeader() throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        let idempotencyKey = urlRequest.value(forHTTPHeaderField: "Idempotency-Key")
        XCTAssertEqual(idempotencyKey, request.id)
    }

    func test_urlRequest_addsJsonContentTypeHeader() throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        let idempotencyKey = urlRequest.value(forHTTPHeaderField: "Content-Type")
        XCTAssertEqual(idempotencyKey, "application/json")
    }

    func test_urlRequest_whenRequestHeaderIsSet_overridesDefaultHeader() throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "", headers: ["Content-Type": "test"])

        // When
        let urlRequest = try sut.urlRequest(from: request)

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
            configuration: configuration,
            encoder: encoder,
            deviceMetadataProvider: StubDeviceMetadataProvider(),
            logger: .stub
        )
        return mapper
    }

    private var defaultConfiguration: HttpConnectorRequestMapperConfiguration {
        .init(baseUrl: Constants.baseUrl, projectId: "<ID>", privateKey: "<KEY>", version: "1.2.3", appVersion: "4.5.6")
    }
}
