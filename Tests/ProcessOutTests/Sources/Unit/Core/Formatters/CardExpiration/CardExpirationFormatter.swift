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
        let formattedNumber = sut.string(from: "1230")

        // Then
        XCTAssertEqual(formattedNumber, "12 / 30")
    }

    func test_string_whenValidMonthIsPrefixedWithZeros_keepsZingleZero() {
        // When
        let formattedNumber = sut.string(from: "001")

        // Then
        XCTAssertEqual(formattedNumber, "01 / ")
    }

    // MARK: - Private Properties

    private var sut: CardExpirationFormatter!
}
