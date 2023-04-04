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

    func test_urlRequest_whenRequestIncludesDeviceMetadataButBodyIsNotSet_fails() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.post(path: "", includesDeviceMetadata: true)

        // When
        do {
            _ = try sut.urlRequest(from: request)
        } catch HttpConnectorFailure.internal {
            // Then
            return
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func test_urlRequest_whenBodyIsNotSet_returnsRequestWithoutBody() throws {
        // Given
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: Constants.baseUrl, projectId: "", privateKey: nil, version: ""
        )
        let sut = createMapper(configuration: configuration)
        let request = HttpConnectorRequest<VoidCodable>.post(path: "")

        // When
        let urlRequest = try sut.urlRequest(from: request)

        // Then
        XCTAssertNil(urlRequest.httpBody)
    }

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

    func test_urlRequest_whenAdditionalHeaderIsSet_addsIt() throws {
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

    // when body is set and adds metadata encodes it
    // when body is set encodes it (without metadata)
    // when body encoding fails, it fails

//    func test_urlRequest_whenRequestIncludesDeviceMetadata_encodesDeviceMetadata() throws {
//        // Given
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .sortedKeys
//        let deviceMetadata = DeviceMetadata(
//            appLanguage: "en", appScreenWidth: 1, appScreenHeight: 2, appTimeZoneOffset: 0, channel: "ios"
//        )
//        let body = ["key": 1]
//        let decoratedBody = HttpConnectorDecoratedRequestBody(
//            body: POAnyEncodable(body), deviceMetadata: deviceMetadata
//        )
//
//        // When
//        let encodedData = try encoder.encode(decoratedBody)
//
//        // Then
//        // swiftlint:disable:next line_length
//        let expectedValue = #"{"device":{"appLanguage":"en","appScreenHeight":2,"appScreenWidth":1,"appTimeZoneOffset":0,"channel":"ios"},"key":1}"#
//        XCTAssertEqual(Data(expectedValue.utf8), encodedData)
//    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let baseUrl = URL(string: "https://example.com")! // swiftlint:disable:this force_unwrapping
    }

    // MARK: - Private Methods

    private func createMapper(configuration: HttpConnectorRequestMapperConfiguration) -> HttpConnectorRequestMapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let mapper = HttpConnectorRequestMapper(
            configuration: configuration,
            encoder: JSONEncoder(),
            deviceMetadataProvider: DeviceMetadataProvider(screen: .main, bundle: .main),
            logger: POLogger()
        )
        return mapper
    }
}
