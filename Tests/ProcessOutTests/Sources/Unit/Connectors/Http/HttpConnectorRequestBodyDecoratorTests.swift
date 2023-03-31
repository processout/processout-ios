//
//  HttpConnectorRequestBodyDecoratorTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 31.03.2023.
//

import XCTest
@testable import ProcessOut

final class HttpConnectorRequestBodyDecoratorTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_encode_whenBodyIsObject_encodesDeviceMetadata() throws {
        // Given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let deviceMetadata = DeviceMetadata(
            appLanguage: "en", appScreenWidth: 1, appScreenHeight: 2, appTimeZoneOffset: 0, channel: "ios"
        )
        let body = ["key": 1]
        let decoratedBody = HttpConnectorRequestBodyDecorator(
            body: POAnyEncodable(body), deviceMetadata: deviceMetadata
        )

        // When
        let encodedData = try encoder.encode(decoratedBody)

        // Then
        // swiftlint:disable:next line_length
        let expectedValue = #"{"device":{"appLanguage":"en","appScreenHeight":2,"appScreenWidth":1,"appTimeZoneOffset":0,"channel":"ios"},"key":1}"#
        XCTAssertEqual(Data(expectedValue.utf8), encodedData)
    }
}
