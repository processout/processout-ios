//
//  FormattingUtilsTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.05.2023.
//

import XCTest
@testable import ProcessOut

final class FormattingUtilsTests: XCTestCase {

    func test_adjustedCursorOffset_whenNotGreedy_doesNotIncludeSignificants() {
        // When
        let offset = FormattingUtils.adjustedCursorOffset(
            in: "1 2", source: "12", sourceCursorOffset: 1, significantCharacters: .decimalDigits, greedy: false
        )

        // Then
        XCTAssertEqual(offset, 1)
    }

    func test_adjustedCursorOffset_whenGreedy_includesNonSignificants() {
        // When
        let offset = FormattingUtils.adjustedCursorOffset(
            in: "1 2", source: "12", sourceCursorOffset: 1, significantCharacters: .decimalDigits
        )

        // Then
        XCTAssertEqual(offset, 2)
    }

    func test_adjustedCursorOffset_whenCursorPrefixIncreases_returnEndOfTarget() { // should fail
        // When
        let offset = FormattingUtils.adjustedCursorOffset(
            in: "+1", source: "1", sourceCursorOffset: 1, significantCharacters: .decimalDigits
        )

        // Then
        XCTAssertEqual(offset, 2)
    }

    func test_adjustedCursorOffset_whenCursorPrefixChanges_returnEndOfTarget() { // should fail
        // When
        let offset = FormattingUtils.adjustedCursorOffset(
            in: "32", source: "12", sourceCursorOffset: 1, significantCharacters: .decimalDigits
        )

        // Then
        XCTAssertEqual(offset, 2)
    }

    func test_adjustedCursorOffset_whenCursorSuffixChanges_returnSameOffset() { // should fail
        // When
        let offset = FormattingUtils.adjustedCursorOffset(
            in: "12", source: "1", sourceCursorOffset: 1, significantCharacters: .decimalDigits
        )

        // Then
        XCTAssertEqual(offset, 1)
    }
}
