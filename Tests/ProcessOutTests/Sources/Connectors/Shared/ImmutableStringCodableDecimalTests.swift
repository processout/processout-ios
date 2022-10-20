//
//  ImmutableStringCodableDecimalTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.10.2022.
//

import XCTest
@testable import ProcessOut

final class ImmutableStringCodableDecimalTests: XCTestCase {

    override func setUp() {
        super.setUp()
        encoder = JSONEncoder()
        decoder = JSONDecoder()
    }

    func test_init_whenInputIsInteger_succeeds() throws {
        // Given
        let data = Data(#""1""#.utf8)

        // When
        let decimal = try decoder.decode(ImmutableStringCodableDecimal.self, from: data)

        // Then
        XCTAssertEqual(decimal.wrappedValue.description, "1")
    }

    func test_init_whenInputHasSingleDotDecimalSeparator_succeeds() throws {
        // Given
        let data = Data(#""1234.25""#.utf8)

        // When
        let decimal = try decoder.decode(ImmutableStringCodableDecimal.self, from: data)

        // Then
        XCTAssertEqual(decimal.wrappedValue.description, "1234.25")
    }

    func test_init_whenInputIsNotString_fails() throws {
        // Given
        let data = Data("1".utf8)

        // Then
        XCTAssertThrowsError(try decoder.decode(ImmutableStringCodableDecimal.self, from: data))
    }

    func test_init_whenInputHasComma_fails() throws {
        // Given
        let data = Data(#""1,2""#.utf8)

        // Then
        XCTAssertThrowsError(try decoder.decode(ImmutableStringCodableDecimal.self, from: data))
    }

    func test_encode_returnsStringData() throws {
        // Given
        let decimal = ImmutableStringCodableDecimal(value: Decimal(1234))

        // When
        let data = try encoder.encode(decimal)

        // Then
        let expectedData = Data(#""1234""#.utf8)
        XCTAssertEqual(data, expectedData)
    }

    // MARK: - Private Properties

    private var encoder: JSONEncoder! // swiftlint:disable:this implicitly_unwrapped_optional
    private var decoder: JSONDecoder! // swiftlint:disable:this implicitly_unwrapped_optional
}
