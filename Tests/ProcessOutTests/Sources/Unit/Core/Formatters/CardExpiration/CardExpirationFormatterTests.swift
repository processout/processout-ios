//
//  CardExpirationFormatterTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.07.2023.
//

import Testing
@testable @_spi(PO) import ProcessOut

struct CardExpirationFormatterTests {

    init() {
        sut = POCardExpirationFormatter()
    }

    @Test
    func string() {
        // When
        let formatted = sut.string(from: "1230")

        // Then
        #expect(formatted == "12 / 30")
    }

    @Test
    func string_whenStringHasNoDigits_returnsEmptyString() {
        // When
        let formatted = sut.string(from: "a")

        // Then
        #expect(formatted.isEmpty)
    }

    @Test
    func string_whenStringIsPrefixedWithZeros_keepsZingleZero() {
        // When
        let formatted = sut.string(from: "001")

        // Then
        #expect(formatted == "01 / ")
    }

    @Test
    func string_whenStringHasOnlyZeros_returnsZero() {
        // When
        let formatted = sut.string(from: "000")

        // Then
        #expect(formatted == "0")
    }

    @Test
    func string_returnsPaddedMonth() {
        // Given
        let strings = (2...9).map(\.description)

        // When
        let formatted = strings.map(sut.string(from:))

        // Then
        let allSatisfy = formatted.allSatisfy { $0.first == "0" }
        #expect(allSatisfy)
    }

    @Test
    func string_whenMonthIsIncomplete_returnsIt() {
        // When
        let formatted = sut.string(from: "1")

        // Then
        #expect(formatted == "1")
    }

    // MARK: - Expiration Month

    @Test
    func expirationMonth_returnsValue() {
        // When
        let month = sut.expirationMonth(from: "01")

        // Then
        #expect(month == 1)
    }

    @Test
    func expirationMonth_whenMonthIsInvalid_returnsNil() {
        // When
        let month = sut.expirationMonth(from: "0")

        // Then
        #expect(month == nil)
    }

    // MARK: - Expiration Year

    @Test
    func expirationYear_returnsValue() {
        // When
        let year = sut.expirationYear(from: "01/1")

        // Then
        #expect(year == 1)
    }

    @Test
    func expirationYear_whenYearComponentIsNotSet_returnsNil() {
        // When
        let year = sut.expirationYear(from: "01/")

        // Then
        #expect(year == nil)
    }

    // MARK: - Private Properties

    private let sut: POCardExpirationFormatter
}
