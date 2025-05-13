//
//  FallbackDecodableTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 24.11.2023.
//

import Foundation
import Testing
@testable import ProcessOut

struct FallbackDecodableTests {

    @Test
    func fallbackDecodable_whenValueIsNotPresent_decodesEmptyString() throws {
        // Given
        let decoder = JSONDecoder()
        let data = Data("{}".utf8)

        // When
        let container = try decoder.decode(Container.self, from: data)

        // Then
        #expect(container.value.isEmpty)
    }

    @Test
    func fallbackDecodable_whenValueIsNull_decodesEmptyString() throws {
        // Given
        let decoder = JSONDecoder()
        let data = Data(#"{ "value": null }"#.utf8)

        // When
        let container = try decoder.decode(Container.self, from: data)

        // Then
        #expect(container.value.isEmpty)
    }

    @Test
    func fallbackDecodable_whenValueIsAvailable_decodesIt() throws {
        // Given
        let decoder = JSONDecoder()
        let data = Data(#"{ "value": "1" }"#.utf8)

        // When
        let container = try decoder.decode(Container.self, from: data)

        // Then
        #expect(container.value == "1")
    }

    @Test
    func encode() throws {
        // Given
        let sut = Container(value: "")
        let encoder = JSONEncoder()

        // Then
        let encoded = String(decoding: try encoder.encode(sut), as: UTF8.self)
        #expect(encoded == #"{"value":""}"#)
    }
}

private struct Container: Codable {

    @POFallbackDecodable<POEmptyStringProvider>
    var value: String
}
