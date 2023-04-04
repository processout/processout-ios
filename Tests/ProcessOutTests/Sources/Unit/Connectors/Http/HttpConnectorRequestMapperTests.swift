//
//  HttpConnectorRequestMapperTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2023.
//

import Foundation
import XCTest
@testable import ProcessOut

final class HttpConnectorRequestMapperTests: XCTestCase {

    func test_urlRequest_whenBaseUrlIsMalformed_fails() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            // swiftlint:disable:next force_unwrapping
            baseUrl: URL(string: "http://example.com:-80")!, projectId: "", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // Then
        XCTAssertThrowsError(try sut.urlRequest(from: request))
    }

    func test_urlRequest_whenRequestPathIsInvalid_fails() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "|")

        // Then
        XCTAssertThrowsError(try sut.urlRequest(from: request))
    }

    func test_urlRequest_whenRequestPathIsValid_returnsRequestWithSamePath() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "/test/path")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        XCTAssertEqual(urlRequest.url?.path(), request.path)
    }

    // MARK: - Body

    func test_urlRequest_whenBodyIsSet_encodesBody() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let body = "body"
        let request = HttpConnectorRequest<VoidCodable>.post(path: "", body: body)

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        XCTAssertEqual(urlRequest.httpBody, Data(#""body""#.utf8))
    }

    func test_urlRequest_whenRequestIncludesDeviceMetadataButBodyIsNotSet_encodesBody() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.post(path: "", includesDeviceMetadata: true)

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        // swiftlint:disable:next line_length
        let expectedBody = #"{"device":{"appLanguage":"language","appScreenHeight":2,"appScreenWidth":1,"appTimeZoneOffset":3,"channel":"test"}}"#
        XCTAssertEqual(urlRequest.httpBody, Data(expectedBody.utf8))
    }

    func test_urlRequest_whenBodyIsSetAndRequestIncludesDeviceMetadata_encodesBody() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let body = ["key": "value"]
        let request = HttpConnectorRequest<VoidCodable>.post(path: "", body: body, includesDeviceMetadata: true)

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        // swiftlint:disable:next line_length
        let expectedBody = #"{"device":{"appLanguage":"language","appScreenHeight":2,"appScreenWidth":1,"appTimeZoneOffset":3,"channel":"test"},"key":"value"}"#
        XCTAssertEqual(urlRequest.httpBody, Data(expectedBody.utf8))
    }

    func test_urlRequest_whenBodyIsNotSet_returnsRequestWithoutBody() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        XCTAssertNil(urlRequest.httpBody)
    }

    func test_urlRequest_whenBodyIsInvalid_fails() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.post(path: "", body: Float.infinity)

        // Then
        XCTAssertThrowsError(try sut.urlRequest(from: request)) { error in
            switch error {
            case HttpConnectorFailure.coding:
                break
            default:
                XCTFail("Unexpected failure")
            }
        }
    }

    // MARK: - Query

    func test_urlRequest_whenQueryIsSet_returnsRequestWithQuery() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "", query: ["key": "value"])

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        XCTAssertEqual(urlRequest.url?.query(), "key=value")
    }

    // MARK: - Headers

    func test_urlRequest_returnsRequestWithValidUserAgent() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: "X-Y-Z"
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        let userAgent = urlRequest.value(forHTTPHeaderField: "user-agent")
        let userAgentRegex = /^iOS\/Version\/.*\/ProcessOut iOS-Bindings\/X-Y-Z$/
        XCTAssertNotNil(userAgent?.firstMatch(of: userAgentRegex))
    }

    func test_urlRequest_whenPrivateKeyIsNotRequired_addsAuthorization() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "PROJECT_ID", privateKey: "PRIVATE_KEY", version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        let authorization = urlRequest.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authorization, "Basic UFJPSkVDVF9JRDo=")
    }

    func test_urlRequest_whenPrivateKeyIsRequired_addsAuthorization() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "PROJECT_ID", privateKey: "PRIVATE_KEY", version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "", requiresPrivateKey: true)

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        let authorization = urlRequest.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authorization, "Basic UFJPSkVDVF9JRDpQUklWQVRFX0tFWQ==")
    }

    func test_urlRequest_whenPrivateKeyIsRequiredButNotSet_fails() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "PROJECT_ID", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "", requiresPrivateKey: true)

        // Then
        XCTAssertThrowsError(try sut.urlRequest(from: request))
    }

    func test_urlRequest_addsDefaultHeaders() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        let expectedHeaders = ["Idempotency-Key", "User-Agent", "Accept-Language", "Content-Type", "Authorization"]
        for header in expectedHeaders {
            XCTAssertNotNil(urlRequest.value(forHTTPHeaderField: header))
        }
    }

    func test_urlRequest_addsValidIdempotencyKey() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        let idempotencyKey = urlRequest.value(forHTTPHeaderField: "Idempotency-Key")
        XCTAssertEqual(idempotencyKey, request.id)
    }

    func test_urlRequest_addsValidJsonContentTypeKey() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        let idempotencyKey = urlRequest.value(forHTTPHeaderField: "Content-Type")
        XCTAssertEqual(idempotencyKey, "application/json")
    }

    func test_urlRequest_whenRequestHeaderIsSet_addsIt() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.get(path: "", headers: ["key": "value"])

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "key"), "value")
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let baseUrl = URL(string: "https://example.com")! // swiftlint:disable:this force_unwrapping
    }

    // MARK: - Private Methods

    private func createMapper(configuration: HttpConnectorRequestMapperConfiguration) -> HttpConnectorRequestMapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let mockDeviceMetadata = DeviceMetadata(
            appLanguage: "language",
            appScreenWidth: 1,
            appScreenHeight: 2,
            appTimeZoneOffset: 3,
            channel: "test"
        )
        let mapper = HttpConnectorRequestMapper(
            configuration: configuration,
            encoder: encoder,
            deviceMetadataProvider: MockDeviceMetadataProvider(deviceMetadata: mockDeviceMetadata),
            logger: POLogger()
        )
        return mapper
    }
}
