//
//  FallbackDecodableTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 24.11.2023.
//

import XCTest
@testable import ProcessOut

final class FallbackDecodableTests: XCTestCase {

    func test_fallbackDecodable_whenValueIsNotPresent_decodesEmptyString() throws {
        // Given
        let decoder = JSONDecoder()
        let data = Data("{}".utf8)

        // When
        let container = try decoder.decode(Container.self, from: data)

        // Then
        XCTAssertTrue(container.value.isEmpty)
    }

    func test_fallbackDecodable_whenValueIsNull_decodesEmptyString() throws {
        // Given
        let decoder = JSONDecoder()
        let data = Data(#"{ "value": null }"#.utf8)

        // When
        let container = try decoder.decode(Container.self, from: data)

        // Then
        XCTAssertTrue(container.value.isEmpty)
    }

    func test_fallbackDecodable_whenValueIsAvailable_decodesIt() throws {
        // Given
        let decoder = JSONDecoder()
        let data = Data(#"{ "value": "1" }"#.utf8)

        // When
        let container = try decoder.decode(Container.self, from: data)

        // Then
        XCTAssertEqual(container.value, "1")
    }
}

private struct Container: Decodable {

    @POFallbackDecodable<POEmptyStringProvider>
    var value: String
}
