//
//  CardholderNameDetectorTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.12.2024.
//

import Testing
@_spi(PO) import ProcessOut
@testable import ProcessOutUI

struct CardholderNameDetectorTests {

    @Test
    func firstMatch_whenCandidateDoesntIncludeRestrictedWords_matches() {
        // Given
        let sut = CardholderNameDetector(restrictedWords: ["RESTRICTED"])

        // When
        var candidates = ["Test"]

        // Then
        let match = sut.firstMatch(in: &candidates)
        #expect(match == "Test" && candidates.isEmpty)
    }

    @Test
    func firstMatch_whenCandidateIncludesRestrictedWordAndCaseIsDifferent_doesntMatch() {
        // Given
        let restrictedWord = "RESTRICTED"
        let sut = CardholderNameDetector(restrictedWords: [restrictedWord])

        // When
        var candidates = [restrictedWord.lowercased()]

        // Then
        #expect(sut.firstMatch(in: &candidates) == nil && candidates.count == 1)
    }

    @Test
    func firstMatch_whenCandidateIncludesRestrictedWithOneLetterDifference_matches() {
        // Given
        let sut = CardholderNameDetector(restrictedWords: ["Visa"])

        // When
        var candidates = ["LISA"]

        // Then
        #expect(sut.firstMatch(in: &candidates) == "LISA" && candidates.isEmpty)
    }

    @Test
    func firstMatch_whenCandidateWithMultipleWordsIncludesRestrictedWord_doesntMatch() {
        // Given
        let sut = CardholderNameDetector(restrictedWords: ["TEST"])

        // When
        var candidates = ["One test two"]

        // Then
        #expect(sut.firstMatch(in: &candidates) == nil)
    }
}
