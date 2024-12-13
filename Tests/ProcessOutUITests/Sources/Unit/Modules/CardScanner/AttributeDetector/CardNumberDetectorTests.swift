//
//  CardNumberDetectorTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.12.2024.
//

import XCTest
@_spi(PO) import ProcessOut
@testable import ProcessOutUI

final class CardNumberDetectorTests: XCTestCase {

    func test_firstMatch_whenCandidateLengthAndChecksumAreValid_matches() {
        // Given
        let sut = CardNumberDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = ["424242424242"]

        // Then
        let match = sut.firstMatch(in: &candidates)
        XCTAssertEqual(match, "4242 4242 4242")
        XCTAssertTrue(candidates.isEmpty)
    }

    func test_firstMatch_whenValidCandidateContainsWhitespaces_matches() {
        // Given
        let sut = CardNumberDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = ["4242 4242\t4242"]

        // Then
        let match = sut.firstMatch(in: &candidates)
        XCTAssertEqual(match, "4242 4242 4242")
        XCTAssertTrue(candidates.isEmpty)
    }

    func test_firstMatch_whenCandidatesContainsValidAndInvalidNumbers_matchesValid() {
        // Given
        let sut = CardNumberDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = [
            "TEST", "4242 4242 4242"
        ]

        // Then
        let match = sut.firstMatch(in: &candidates)
        XCTAssertEqual(match, "4242 4242 4242")
        XCTAssertEqual(candidates, ["TEST"])
    }

    func test_firstMatch_whenCandidateLengthIsValidButChecksumIsInvalid_doesNotMatch() {
        // Given
        let sut = CardNumberDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = ["4242424242424243"] // Invalid checksum

        // Then
        let match = sut.firstMatch(in: &candidates)
        XCTAssertNil(match)
        XCTAssertEqual(candidates.count, 1)
    }

    func test_firstMatch_whenCandidatesAreTooShort_doesNotMatch() {
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
        let match = sut.firstMatch(in: &candidates)
        XCTAssertNil(match)
        XCTAssertEqual(candidates.count, 11)
    }

    func test_firstMatch_whenCandidateIsTooLong_doesNotMatch() {
        // Given
        let sut = CardNumberDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = ["4242 4242 4242 4242 4242"]

        // Then
        let match = sut.firstMatch(in: &candidates)
        XCTAssertNil(match)
        XCTAssertEqual(candidates.count, 1)
    }
}
