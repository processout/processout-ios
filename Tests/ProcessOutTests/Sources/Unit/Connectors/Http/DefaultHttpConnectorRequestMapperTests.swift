//
//  DefaultHttpConnectorRequestMapperTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 03.04.2023.
//

import Foundation
import Testing
@testable @_spi(PO) import ProcessOut

struct DefaultHttpConnectorRequestMapperTests {

    // MARK: - Request Path

    @Test
    func urlRequest_whenPathIsInvalid_fails() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "|")

        // Then
        await withKnownIssue {
            _ = try await sut.urlRequest(from: request)
        }
    }

    @Test
    func urlRequest_whenPathIsValid_succeeds() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "/test/path")

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        #expect(urlRequest.url?.path() == request.path)
    }

    // MARK: - Request Body

    @Test
    func urlRequest_whenBodyIsSet_encodesBody() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.post(path: "", body: "body")

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        #expect(urlRequest.httpBody == Data(#""body""#.utf8))
    }

    @Test
    func urlRequest_whenIncludesDeviceMetadataButBodyIsNotSet_encodesBody() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.post(path: "", includesDeviceMetadata: true)

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        // swiftlint:disable:next line_length
        let expectedBody = #"{"device":{"appLanguage":"en","appScreenHeight":2,"appScreenWidth":1,"appTimeZoneOffset":3,"channel":"test","id":"id"}}"#
        #expect(urlRequest.httpBody == Data(expectedBody.utf8))
    }

    @Test
    func urlRequest_whenIncludesDeviceMetadataAndBodyIsSet_encodesBody() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.post(
            path: "", body: ["key": "value"], includesDeviceMetadata: true
        )

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        // swiftlint:disable:next line_length
        let expectedBody = #"{"device":{"appLanguage":"en","appScreenHeight":2,"appScreenWidth":1,"appTimeZoneOffset":3,"channel":"test","id":"id"},"key":"value"}"#
        #expect(urlRequest.httpBody == Data(expectedBody.utf8))
    }

    @Test
    func urlRequest_whenBodyIsNotSet_returnsRequestWithoutBody() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        #expect(urlRequest.httpBody == nil)
    }

    @Test
    func urlRequest_whenBodyIsInvalid_fails() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.post(path: "", body: Float.infinity)

        // Then
        await withKnownIssue {
            _ = try await sut.urlRequest(from: request)
        }
    }

    // MARK: - Request Query

    @Test
    func urlRequest_whenQueryIsSet_succeeds() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "", query: ["key": "value"])

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        #expect(urlRequest.url?.query() == "key=value")
    }

    // MARK: - Request Headers

    @Test
    func urlRequest_addsUserAgent() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        let userAgent = urlRequest.value(forHTTPHeaderField: "user-agent")
        let userAgentRegex = /^iOS\/4 ProcessOut iOS-Bindings\/1\.2\.3$/
        #expect(userAgent?.firstMatch(of: userAgentRegex) != nil)
    }

    @Test
    func urlRequest_whenPrivateKeyIsNotRequired_addsAuthorization() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        let authorization = urlRequest.value(forHTTPHeaderField: "Authorization")
        #expect(authorization == "Basic PElEPjo=")
    }

    @Test
    func urlRequest_whenPrivateKeyIsRequired_addsAuthorization() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "", requiresPrivateKey: true)

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        let authorization = urlRequest.value(forHTTPHeaderField: "Authorization")
        #expect(authorization == "Basic PElEPjo8S0VZPg==")
    }

    @Test
    func urlRequest_addsDefaultHeaders() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        let expectedHeaders = ["User-Agent", "Accept-Language", "Content-Type", "Authorization"]
        for header in expectedHeaders {
            #expect(urlRequest.value(forHTTPHeaderField: header) != nil)
        }
    }

    @Test
    func urlRequest_addsJsonContentTypeHeader() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        let idempotencyKey = urlRequest.value(forHTTPHeaderField: "Content-Type")
        #expect(idempotencyKey == "application/json")
    }

    @Test
    func urlRequest_whenRequestHeaderIsSet_overridesDefaultHeader() async throws {
        // Given
        let sut = createMapper(configuration: defaultConfiguration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "", headers: ["Content-Type": "test"])

        // When
        let urlRequest = try await sut.urlRequest(from: request)

        // Then
        #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "test")
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let baseUrl = URL(string: "https://example.com")!
    }

    // MARK: - Private Methods

    private func createMapper(
        configuration: HttpConnectorConfiguration
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

    private var defaultConfiguration: HttpConnectorConfiguration {
        .init(baseUrl: Constants.baseUrl, projectId: "<ID>", privateKey: "<KEY>", sessionId: "<SID>", version: "1.2.3")
    }
}
