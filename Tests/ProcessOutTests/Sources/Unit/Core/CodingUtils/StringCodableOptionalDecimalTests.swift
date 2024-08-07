//
//  StringCodableOptionalDecimalTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 18.10.2022.
//

import Foundation
import XCTest
@testable import ProcessOut

final class ImmutableStringCodableOptionalDecimalTests: XCTestCase {

    override func setUp() {
        super.setUp()
        encoder = JSONEncoder()
        decoder = JSONDecoder()
    }

    func test_init_whenInputIsInteger_succeeds() throws {
        // Given
        let data = Data(#""1""#.utf8)

        // When
        let decimal = try decoder.decode(POStringCodableOptionalDecimal.self, from: data)

        // Then
        XCTAssertEqual(decimal.wrappedValue?.description, "1")
    }

    func test_init_whenInputHasSingleDotDecimalSeparator_succeeds() throws {
        // Given
        let data = Data(#""1234.25""#.utf8)

        // When
        let decimal = try decoder.decode(POStringCodableOptionalDecimal.self, from: data)

        // Then
        XCTAssertEqual(decimal.wrappedValue?.description, "1234.25")
    }

    func test_decode_whenInContainer_encodesString() throws {
        // Given
        let data = Data(#"{"number":"1234"}"#.utf8)

        // When
        let container = try decoder.decode(Container.self, from: data)

        // Then
        XCTAssertEqual(container.number?.description, "1234")
    }

    func test_init_whenInputIsNotString_fails() throws {
        // Given
        let data = Data("1".utf8)

        // Then
        XCTAssertThrowsError(try decoder.decode(POStringCodableOptionalDecimal.self, from: data))
    }

    func test_init_whenInputHasComma_fails() throws {
        // Given
        let data = Data(#""1,2""#.utf8)

        // Then
        XCTAssertThrowsError(try decoder.decode(POStringCodableOptionalDecimal.self, from: data))
    }

    func test_encode_returnsStringData() throws {
        // Given
        let decimal = POStringCodableOptionalDecimal(value: Decimal(1234))

        // When
        let data = try encoder.encode(decimal)

        // Then
        let expectedData = Data(#""1234""#.utf8)
        XCTAssertEqual(data, expectedData)
    }

    func test_encode_whenInContainer_encodesString() throws {
        // Given
        let value = Container(number: POStringCodableOptionalDecimal(value: Decimal(1234)))

        // When
        let data = try encoder.encode(value)

        // Then
        XCTAssertEqual(Data(#"{"number":"1234"}"#.utf8), data)
    }

    // MARK: - Private Properties

    private var encoder: JSONEncoder!
    private var decoder: JSONDecoder!
}

private struct Container: Codable {

    @POStringCodableOptionalDecimal
    var number: Decimal?
}
