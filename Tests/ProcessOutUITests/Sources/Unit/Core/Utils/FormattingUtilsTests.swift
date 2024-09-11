//
//  FormattingUtilsTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.05.2023.
//

import XCTest
@testable import ProcessOutUI

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

    func test_adjustedCursorOffset_whenCursorPrefixChanges_returnValidOffset() {
        // When
        let offset = FormattingUtils.adjustedCursorOffset(
            in: "+12", source: "12", sourceCursorOffset: 1, significantCharacters: .decimalDigits
        )

        // Then
        XCTAssertEqual(offset, 2)
    }

    func test_adjustedCursorOffset_whenCursorSuffixChanges_returnEndOfTarget() {
        // When
        let offset = FormattingUtils.adjustedCursorOffset(
            in: "2", source: "1", sourceCursorOffset: 0, significantCharacters: .decimalDigits
        )

        // Then
        XCTAssertEqual(offset, 1)
    }

    func test_adjustedCursorOffset_whenNewCharacterIsAddedToCursorSuffix_returnEndOfTarget() {
        // When
        let offset = FormattingUtils.adjustedCursorOffset(
            in: "123", source: "12", sourceCursorOffset: 1, significantCharacters: .decimalDigits
        )

        // Then
        XCTAssertEqual(offset, 3)
    }

    func test_adjustedCursorOffset_whenSourceIsSameAsTarget_returnsSameOffset() {
        // When
        let offset = FormattingUtils.adjustedCursorOffset(
            in: "1", source: "1", sourceCursorOffset: 0, significantCharacters: .decimalDigits
        )

        // Then
        XCTAssertEqual(offset, 0)
    }

    func test_adjustedCursorOffset_whenSourceIsEmpty_returnEndOfTarget() {
        // When
        let offset = FormattingUtils.adjustedCursorOffset(
            in: "1", source: "", sourceCursorOffset: 0, significantCharacters: .decimalDigits
        )

        // Then
        XCTAssertEqual(offset, 1)
    }

    func test_adjustedCursorOffset_whenTargetIsEmpty_returnStartOfTarget() {
        // When
        let offset = FormattingUtils.adjustedCursorOffset(
            in: "", source: "0", sourceCursorOffset: 1, significantCharacters: .decimalDigits
        )

        // Then
        XCTAssertEqual(offset, 0)
    }
}
