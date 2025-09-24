//
//  TypedRepresentationTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 06.03.2025.
//

import Foundation
import Testing
@testable import ProcessOutCore

struct TypedRepresentationTests {

    @Test
    func initWithDecoder() throws {
        // Given
        let value = #"{"value":"test"}"#

        // When
        let sut = try decoder.decode(Container.self, from: Data(value.utf8))

        // Then
        #expect(sut.$value.typed == .test)
    }

    @Test
    func init_whenValueIsNotSet() throws {
        // Given
        let value = #"{}"#

        // When
        let sut = try decoder.decode(Container.self, from: Data(value.utf8))

        // Then
        #expect(sut.$value.typed == nil)
    }

    @Test
    func encode() throws {
        // Given
        let sut = Container(value: "test")

        // When
        let encoded = String(decoding: try encoder.encode(sut), as: UTF8.self)

        // Then
        #expect(encoded == #"{"value":"test"}"#)
    }

    // MARK: - Private Properties

    private let decoder = JSONDecoder(), encoder = JSONEncoder()
}

private struct Container: Codable {

    @POTypedRepresentation<String?, TestRepresentation>
    var value: String?
}

private struct TestRepresentation: RawRepresentable, Equatable {

    let rawValue: String

    /// Test value.
    static let test = TestRepresentation(rawValue: "test")
}
