//
//  FormattingUtilsTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.05.2023.
//

import Testing
@testable @_spi(PO) import ProcessOut

struct FormattingUtilsTests {

    @Test
    func adjustedCursorOffset_whenNotGreedy_doesNotIncludeSignificants() {
        // When
        let offset = POFormattingUtils.adjustedCursorOffset(
            in: "1 2", source: "12", sourceCursorOffset: 1, significantCharacters: .decimalDigits, greedy: false
        )

        // Then
        #expect(offset == 1)
    }

    @Test
    func adjustedCursorOffset_whenGreedy_includesNonSignificants() {
        // When
        let offset = POFormattingUtils.adjustedCursorOffset(
            in: "1 2", source: "12", sourceCursorOffset: 1, significantCharacters: .decimalDigits
        )

        // Then
        #expect(offset == 2)
    }

    @Test
    func adjustedCursorOffset_whenCursorPrefixChanges_returnValidOffset() {
        // When
        let offset = POFormattingUtils.adjustedCursorOffset(
            in: "+12", source: "12", sourceCursorOffset: 1, significantCharacters: .decimalDigits
        )

        // Then
        #expect(offset == 2)
    }

    @Test
    func adjustedCursorOffset_whenCursorSuffixChanges_returnEndOfTarget() {
        // When
        let offset = POFormattingUtils.adjustedCursorOffset(
            in: "2", source: "1", sourceCursorOffset: 0, significantCharacters: .decimalDigits
        )

        // Then
        #expect(offset == 1)
    }

    @Test
    func adjustedCursorOffset_whenNewCharacterIsAddedToCursorSuffix_returnEndOfTarget() {
        // When
        let offset = POFormattingUtils.adjustedCursorOffset(
            in: "123", source: "12", sourceCursorOffset: 1, significantCharacters: .decimalDigits
        )

        // Then
        #expect(offset == 3)
    }

    @Test
    func adjustedCursorOffset_whenSourceIsSameAsTarget_returnsSameOffset() {
        // When
        let offset = POFormattingUtils.adjustedCursorOffset(
            in: "1", source: "1", sourceCursorOffset: 0, significantCharacters: .decimalDigits
        )

        // Then
        #expect(offset == 0)
    }

    @Test
    func adjustedCursorOffset_whenSourceIsEmpty_returnEndOfTarget() {
        // When
        let offset = POFormattingUtils.adjustedCursorOffset(
            in: "1", source: "", sourceCursorOffset: 0, significantCharacters: .decimalDigits
        )

        // Then
        #expect(offset == 1)
    }

    @Test
    func adjustedCursorOffset_whenTargetIsEmpty_returnStartOfTarget() {
        // When
        let offset = POFormattingUtils.adjustedCursorOffset(
            in: "", source: "0", sourceCursorOffset: 1, significantCharacters: .decimalDigits
        )

        // Then
        #expect(offset == 0)
    }
}
