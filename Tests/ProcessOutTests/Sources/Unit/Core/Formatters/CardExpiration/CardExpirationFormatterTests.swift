//
//  CardExpirationFormatter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.07.2023.
//

import XCTest
@testable import ProcessOut

final class CardExpirationFormatterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        sut = CardExpirationFormatter()
    }

    func test_string() {
        // When
        let formatted = sut.string(from: "1230")

        // Then
        XCTAssertEqual(formatted, "12 / 30")
    }

    func test_string_whenStringHasNoDigits_returnsEmptyString() {
        // When
        let formatted = sut.string(from: "a")

        // Then
        XCTAssertEqual(formatted, "")
    }

    func test_string_whenStringIsPrefixedWithZeros_keepsZingleZero() {
        // When
        let formatted = sut.string(from: "001")

        // Then
        XCTAssertEqual(formatted, "01 / ")
    }

    func test_string_whenStringHasOnlyZeros_returnsZero() {
        // When
        let formatted = sut.string(from: "000")

        // Then
        XCTAssertEqual(formatted, "0")
    }

    func test_string_returnsPaddedMonth() {
        // Given
        let strings = (2...9).map(\.description)

        // When
        let formatted = strings.map(sut.string(from:))

        // Then
        let allSatisfy = formatted.allSatisfy { $0.first == "0" }
        XCTAssertTrue(allSatisfy)
    }

    func test_string_whenMonthIsIncomplete_returnsIt() {
        // When
        let formatted = sut.string(from: "1")

        // Then
        XCTAssertEqual(formatted, "1")
    }

    // MARK: - Expiration Month

    func test_expirationMonth_returnsValue() {
        // When
        let month = sut.expirationMonth(from: "01")

        // Then
        XCTAssertEqual(month, 1)
    }

    func test_expirationMonth_whenMonthIsInvalid_returnsNil() {
        // When
        let month = sut.expirationMonth(from: "0")

        // Then
        XCTAssertEqual(month, nil)
    }

    // MARK: - Expiration Year

    func test_expirationYear_returnsValue() {
        // When
        let year = sut.expirationYear(from: "01/1")

        // Then
        XCTAssertEqual(year, 1)
    }

    func test_expirationYear_whenYearComponentIsNotSet_returnsNil() {
        // When
        let year = sut.expirationYear(from: "01/")

        // Then
        XCTAssertEqual(year, nil)
    }

    // MARK: - Private Properties

    private var sut: CardExpirationFormatter!
}
