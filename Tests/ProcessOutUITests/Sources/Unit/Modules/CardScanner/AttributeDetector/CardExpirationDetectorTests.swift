//
//  CardExpirationDetectorTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.12.2024.
//

import XCTest
@_spi(PO) import ProcessOut
@testable import ProcessOutUI

final class CardExpirationDetectorTests: XCTestCase {

    func test_firstMatch_whenMonthAndYearAreValid_matches() {
        // Given
        let sut = CardExpirationDetector(regexProvider: .shared, formatter: .init())

        // When
        let validExpirationMonths = 1...12

        // Then
        for month in validExpirationMonths {
            var candidates = expirations(months: month...month, monthFormat: "%02d", year: "40")
            let match = sut.firstMatch(in: &candidates)
            XCTAssertTrue(match?.month == month && match?.year == 2040)
            XCTAssertTrue(candidates.isEmpty)
        }
    }

    func test_firstMatch_whenValidCandidateContainsWhitespaces_matches() {
        // Given
        let sut = CardExpirationDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = ["01 /\t40"]

        // Then
        let match = sut.firstMatch(in: &candidates)
        XCTAssertTrue(match?.month == 1 && match?.year == 2040)
        XCTAssertTrue(candidates.isEmpty)
    }

    func test_firstMatch_whenMonthIsInvalid_doesNotMatch() {
        // Given
        let sut = CardExpirationDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = [
            ["0", "00"],
            expirations(months: 1...9, monthFormat: "%d", year: "40"),
            expirations(months: 13...99, monthFormat: "%d", year: "40")
        ].flatMap { $0 }

        // Then
        XCTAssertNil(sut.firstMatch(in: &candidates))
        XCTAssertEqual(candidates.count, 98)
    }

    func test_firstMatch_whenDateIsInPast_doesNotMatchButConsumesCandidate() {
        // Given
        let sut = CardExpirationDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = ["01/01"]

        // Then
        XCTAssertNil(sut.firstMatch(in: &candidates))
        XCTAssertTrue(candidates.isEmpty)
    }

    func test_firstMatch_whenCandidatesContainsValidAndInvalidExpirations_matchesValid() {
        // Given
        let sut = CardExpirationDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = [
            "TEST", "04/40"
        ]

        // Then
        let match = sut.firstMatch(in: &candidates)
        XCTAssertTrue(match?.month == 4 && match?.year == 2040)
        XCTAssertEqual(candidates, ["TEST"])
    }

    // MARK: - Utils

    private func expirations(months: ClosedRange<Int>, monthFormat: String, year: String) -> [String] {
        months.map { String(format: monthFormat, $0) + "/" + year }
    }
}
