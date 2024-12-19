//
//  CardSecurityCodeFormatterTests.swift
//  ProcessOutUITests
//
//  Created by Andrii Vysotskyi on 14.11.2023.
//

import Testing
@testable import ProcessOutUI

struct CardSecurityCodeFormatterTests {

    init() {
        sut = CardSecurityCodeFormatter()
    }

    @Test
    func string_returnsOnlyDigits() {
        // When
        let formatted = sut.string(from: "1a2")

        // Then
        #expect(formatted == "12")
    }

    @Test
    func string_whenStringHasNoDigits_returnsEmptyString() {
        // When
        let formatted = sut.string(from: "a")

        // Then
        #expect(formatted.isEmpty)
    }

    @Test
    func string_whenSchemeIsNotSetAndInputLengthExceeds4_removesRedundantSuffix() {
        // When
        let formatted = sut.string(from: "12345")

        // Then
        #expect(formatted == "1234")
    }

    @Test
    func string_whenSchemeIsAmexAndInputLengthExceeds4_removesRedundantSuffix() {
        // When
        sut.scheme = .amex
        let formatted = sut.string(from: "12345")

        // Then
        #expect(formatted == "1234")
    }

    @Test
    func string_whenSchemeIsNotAmexAndInputLengthExceeds3_removesRedundantSuffix() {
        // When
        sut.scheme = .visa
        let formatted = sut.string(from: "12345")

        // Then
        #expect(formatted == "123")
    }

    // MARK: - Private Properties

    private let sut: CardSecurityCodeFormatter
}
