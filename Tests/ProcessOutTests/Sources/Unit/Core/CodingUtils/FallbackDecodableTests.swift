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
}

private struct Container: Decodable {

    @POFallbackDecodable<POEmptyStringProvider>
    var value: String
}
