//
//  CardholderNameDetectorTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.12.2024.
//

import XCTest
@_spi(PO) import ProcessOut
@testable import ProcessOutUI

final class CardholderNameDetectorTests: XCTestCase {

    func test_firstMatch_whenCandidateDoesntIncludeRestrictedWords_matches() {
        // Given
        let sut = CardholderNameDetector(restrictedWords: ["RESTRICTED"])

        // When
        var candidates = ["Test"]

        // Then
        let match = sut.firstMatch(in: &candidates)
        XCTAssertEqual(match, "Test")
        XCTAssertTrue(candidates.isEmpty)
    }

    func test_firstMatch_whenCandidateIncludesRestrictedWordAndCaseIsDifferent_doesntMatch() {
        // Given
        let restrictedWord = "RESTRICTED"
        let sut = CardholderNameDetector(restrictedWords: [restrictedWord])

        // When
        var candidates = [restrictedWord.lowercased()]

        // Then
        XCTAssertNil(sut.firstMatch(in: &candidates))
        XCTAssertEqual(candidates.count, 1)
    }

    func test_firstMatch_whenCandidateIncludesRestrictedWithOneLetterDifference_matches() {
        // Given
        let sut = CardholderNameDetector(restrictedWords: ["Visa"])

        // When
        var candidates = ["LISA"]

        // Then
        XCTAssertEqual(sut.firstMatch(in: &candidates), "LISA")
        XCTAssertTrue(candidates.isEmpty)
    }

    func test_firstMatch_whenCandidateWithMultipleWordsIncludesRestrictedWord_doesntMatch() {
        // Given
        let sut = CardholderNameDetector(restrictedWords: ["TEST"])

        // When
        var candidates = ["One test two"]

        // Then
        XCTAssertNil(sut.firstMatch(in: &candidates))
    }
}
