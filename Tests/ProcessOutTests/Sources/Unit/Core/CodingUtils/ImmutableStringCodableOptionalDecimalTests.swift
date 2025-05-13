//
//  ImmutableStringCodableOptionalDecimalTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 18.10.2022.
//

import Foundation
import Testing
@testable import ProcessOut

struct ImmutableStringCodableOptionalDecimalTests {

    init() {
        encoder = JSONEncoder()
        decoder = JSONDecoder()
    }

    @Test
    func init_whenInputIsInteger_succeeds() throws {
        // Given
        let data = Data(#""1""#.utf8)

        // When
        let decimal = try decoder.decode(POImmutableStringCodableOptionalDecimal.self, from: data)

        // Then
        #expect(decimal.wrappedValue?.description == "1")
    }

    @Test
    func init_whenInputHasSingleDotDecimalSeparator_succeeds() throws {
        // Given
        let data = Data(#""1234.25""#.utf8)

        // When
        let decimal = try decoder.decode(POImmutableStringCodableOptionalDecimal.self, from: data)

        // Then
        #expect(decimal.wrappedValue?.description == "1234.25")
    }

    @Test
    func decode_whenInContainerAndValueIsNotSet_decodesNil() throws {
        // Given
        let data = Data(#"{}"#.utf8)

        // When
        let container = try decoder.decode(Container.self, from: data)

        // Then
        #expect(container.number == nil)
    }

    @Test
    func decode_whenInContainer_encodesString() throws {
        // Given
        let data = Data(#"{"number":"1234"}"#.utf8)

        // When
        let container = try decoder.decode(Container.self, from: data)

        // Then
        #expect(container.number?.description == "1234")
    }

    @Test
    func init_whenInputIsNotString_fails() {
        // Given
        let data = Data("1".utf8)

        // Then
        withKnownIssue {
            _ = try decoder.decode(POImmutableStringCodableOptionalDecimal.self, from: data)
        }
    }

    @Test
    func init_whenInputHasComma_fails() {
        // Given
        let data = Data(#""1,2""#.utf8)

        // Then
        withKnownIssue {
            _ = try decoder.decode(POImmutableStringCodableOptionalDecimal.self, from: data)
        }
    }

    @Test
    func encode_returnsStringData() throws {
        // Given
        let decimal = POImmutableStringCodableOptionalDecimal(wrappedValue: Decimal(1234))

        // When
        let data = try encoder.encode(decimal)

        // Then
        #expect(data == Data(#""1234""#.utf8))
    }

    @Test
    func encode_whenInContainer_encodesString() throws {
        // Given
        let value = Container(number: Decimal(1234))

        // When
        let data = try encoder.encode(value)

        // Then
        #expect(Data(#"{"number":"1234"}"#.utf8) == data)
    }

    @Test
    func encode_whenValueIsNil() throws {
        // Given
        let sut = Container(number: nil)

        // When
        let encoded = String(decoding: try encoder.encode(sut), as: UTF8.self)

        // Then
        #expect(#"{}"# == encoded)
    }

    // MARK: - Private Properties

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
}

private struct Container: Codable {

    @POImmutableStringCodableOptionalDecimal
    var number: Decimal?
}
