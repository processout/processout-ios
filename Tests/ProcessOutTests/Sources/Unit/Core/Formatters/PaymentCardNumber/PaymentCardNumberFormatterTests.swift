//
//  PaymentCardNumberFormatterTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.07.2023.
//

import XCTest
@testable import ProcessOut

final class PaymentCardNumberFormatterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        sut = PaymentCardNumberFormatter()
    }

    func test_normalized_retainsDigits() {
        // When
        let normalizedNumber = sut.normalized(number: "+1#")

        // Then
        XCTAssertEqual(normalizedNumber, "1")
    }

    func test_string() {
        // When
        let formattedNumber = sut.string(from: "621")

        // Then
        XCTAssertEqual(formattedNumber, "621")
    }

    // MARK: - Private Properties

    private var sut: PaymentCardNumberFormatter!
}
