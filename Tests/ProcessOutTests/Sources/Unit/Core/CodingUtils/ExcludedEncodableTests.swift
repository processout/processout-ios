//
//  ExcludedEncodableTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 06.03.2025.
//

import Foundation
import Testing
@testable import ProcessOut

struct ExcludedEncodableTests {

    @Test
    func initWithDecoder() throws {
        // Given
        let data = Data(#"{"value":"test"}"#.utf8)

        // When
        let container = try decoder.decode(Container.self, from: data)

        // Then
        #expect(container.value == "test")
    }

    @Test
    func init_whenValueIsNotSet() throws {
        // Given
        let data = Data("{}".utf8)

        // When
        let container = try decoder.decode(Container.self, from: data)

        // Then
        #expect(container.value == nil)
    }

    @Test
    func init_whenValueIsNil() throws {
        // Given
        let data = Data(#"{"value": null}"#.utf8)

        // When
        let container = try decoder.decode(Container.self, from: data)

        // Then
        #expect(container.value == nil)
    }

    @Test
    func encode() throws {
        // Given
        let sut = Container(value: "test")

        // When
        let encoded = String(decoding: try encoder.encode(sut), as: UTF8.self)

        // Then
        #expect(encoded == #"{}"#)
    }

    @Test
    func encode_whenValueIsNil() throws {
        // Given
        let sut = Container(value: "tt")

        // When
        let encoded = String(decoding: try encoder.encode(sut), as: UTF8.self)

        // Then
        #expect(encoded == #"{}"#)
    }

    // MARK: - Private Properties

    private let decoder = JSONDecoder(), encoder = JSONEncoder()
}

private struct Container: Codable {

    @POExcludedEncodable
    var value: String?
}
