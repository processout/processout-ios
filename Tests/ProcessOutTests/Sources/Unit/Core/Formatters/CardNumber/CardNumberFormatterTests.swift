//
//  CardNumberFormatterTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.07.2023.
//

import Testing
@testable @_spi(PO) import ProcessOut

struct CardNumberFormatterTests {

    init() {
        sut = POCardNumberFormatter()
    }

    @Test
    func normalized_retainsDigits() {
        // When
        let normalized = sut.normalized(number: "+1#")

        // Then
        #expect(normalized == "1")
    }

    @Test
    func string_whenHasNoMatchingLeading_fallsBackToDefaultPattern() {
        // When
        let formatted = sut.string(from: "99999")

        // Then
        #expect(formatted == "9999 9")
    }

    @Test
    func string_returnsFormattedNumber() {
        // When
        let formatted = sut.string(from: "123456789123456")

        // Then
        #expect(formatted == "1234 56789 123456")
    }

    @Test
    func string_whenEmpty_returnsEmptyString() {
        // When
        let formatted = sut.string(from: "")

        // Then
        #expect(formatted.isEmpty)
    }

    @Test
    func string_whenExceedsMaxLength_returnsValueWithoutExcessiveSuffix() {
        // When
        let formatted = sut.string(from: "12345678912345678910")

        // Then
        #expect(formatted == "1234 5678 9123 4567 891")
    }

    // MARK: - Private Properties

    private let sut: POCardNumberFormatter
}
