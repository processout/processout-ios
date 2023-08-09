//
//  CardNumberFormatterTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.07.2023.
//

import XCTest
@testable import ProcessOut

final class CardNumberFormatterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        sut = CardNumberFormatter()
    }

    func test_normalized_retainsDigits() {
        // When
        let normalized = sut.normalized(number: "+1#")

        // Then
        XCTAssertEqual(normalized, "1")
    }

    func test_string_whenHasNoMatchingLeading_fallsBackToDefaultPattern() {
        // When
        let formatted = sut.string(from: "99999")

        // Then
        XCTAssertEqual(formatted, "9999 9")
    }

    func test_string_returnsFormattedNumber() {
        // When
        let formatted = sut.string(from: "123456789123456")

        // Then
        XCTAssertEqual(formatted, "1234 56789 123456")
    }

    func test_string_whenEmpty_returnsEmptyString() {
        // When
        let formatted = sut.string(from: "")

        // Then
        XCTAssertEqual(formatted, "")
    }

    func test_string_whenExceedsMaxLength_returnsValueWithoutExcessiveSuffix() {
        // When
        let formatted = sut.string(from: "12345678912345678910")

        // Then
        XCTAssertEqual(formatted, "1234 5678 9123 4567 891")
    }

    // MARK: - Private Properties

    private var sut: CardNumberFormatter!
}
