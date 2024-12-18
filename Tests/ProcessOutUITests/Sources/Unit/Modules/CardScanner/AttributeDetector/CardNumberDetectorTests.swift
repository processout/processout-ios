//
//  CardNumberDetectorTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.12.2024.
//

import Testing
@_spi(PO) import ProcessOut
@testable import ProcessOutUI

struct CardNumberDetectorTests {

    @Test
    func firstMatch_whenCandidateLengthAndChecksumAreValid_matches() {
        // Given
        let sut = CardNumberDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = ["424242424242"]

        // Then
        let match = sut.firstMatch(in: &candidates)
        #expect(match == "4242 4242 4242" && candidates.isEmpty)
    }

    @Test
    func firstMatch_whenValidCandidateContainsWhitespaces_matches() {
        // Given
        let sut = CardNumberDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = ["4242 4242\t4242"]

        // Then
        let match = sut.firstMatch(in: &candidates)
        #expect(match == "4242 4242 4242" && candidates.isEmpty)
    }

    @Test
    func firstMatch_whenCandidatesContainsValidAndInvalidNumbers_matchesValid() {
        // Given
        let sut = CardNumberDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = [
            "TEST", "4242 4242 4242"
        ]

        // Then
        let match = sut.firstMatch(in: &candidates)
        #expect(match == "4242 4242 4242" && candidates == ["TEST"])
    }

    @Test
    func firstMatch_whenCandidateLengthIsValidButChecksumIsInvalid_doesNotMatch() {
        // Given
        let sut = CardNumberDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = ["4242424242424243"] // Invalid checksum

        // Then
        #expect(sut.firstMatch(in: &candidates) == nil && candidates.count == 1)
    }

    @Test
    func firstMatch_whenCandidatesAreTooShort_doesNotMatch() {
        // Given
        let sut = CardNumberDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = [
            "4",
            "42",
            "424",
            "4242",
            "4242 4",
            "4242 42",
            "4242 424",
            "4242 4242",
            "4242 4242 4",
            "4242 4242 42",
            "4242 4242 424"
        ]

        // Then
        #expect(sut.firstMatch(in: &candidates) == nil && candidates.count == 11)
    }

    @Test
    func firstMatch_whenCandidateIsTooLong_doesNotMatch() {
        // Given
        let sut = CardNumberDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = ["4242 4242 4242 4242 4242"]

        // Then
        #expect(sut.firstMatch(in: &candidates) == nil && candidates.count == 1)
    }
}
