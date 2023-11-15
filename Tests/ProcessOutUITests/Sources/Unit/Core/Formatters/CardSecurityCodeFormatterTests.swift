//
//  CardSecurityCodeFormatterTests.swift
//  ProcessOutUITests
//
//  Created by Andrii Vysotskyi on 14.11.2023.
//

import XCTest
@testable import ProcessOutUI

final class CardSecurityCodeFormatterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        sut = CardSecurityCodeFormatter()
    }

    func test_string_returnsOnlyDigits() {
        // When
        let formatted = sut.string(from: "1a2")

        // Then
        XCTAssertEqual(formatted, "12")
    }

    func test_string_whenStringHasNoDigits_returnsEmptyString() {
        // When
        let formatted = sut.string(from: "a")

        // Then
        XCTAssertEqual(formatted, "")
    }

    func test_string_whenSchemeIsNotSetAndInputLengthExceeds4_removesRedundantSuffix() {
        // When
        let formatted = sut.string(from: "12345")

        // Then
        XCTAssertEqual(formatted, "1234")
    }

    func test_string_whenSchemeIsAmexAndInputLengthExceeds4_removesRedundantSuffix() {
        // When
        sut.scheme = "american express"
        let formatted = sut.string(from: "12345")

        // Then
        XCTAssertEqual(formatted, "1234")
    }

    func test_string_whenSchemeIsNotAmexAndInputLengthExceeds3_removesRedundantSuffix() {
        // When
        sut.scheme = "visa"
        let formatted = sut.string(from: "12345")

        // Then
        XCTAssertEqual(formatted, "123")
    }

    // MARK: - Private Properties

    private var sut: CardSecurityCodeFormatter!
}
