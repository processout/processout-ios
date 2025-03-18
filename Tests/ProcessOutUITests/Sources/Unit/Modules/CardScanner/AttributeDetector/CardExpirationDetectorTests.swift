//
//  CardExpirationDetectorTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.12.2024.
//

import Testing
@_spi(PO) import ProcessOut
@testable import ProcessOutUI

struct CardExpirationDetectorTests {

    @Test
    func firstMatch_whenMonthAndYearAreValid_matches() {
        // Given
        let sut = CardExpirationDetector(regexProvider: .shared, formatter: .init())

        // When
        let validExpirationMonths = 1...12

        // Then
        for month in validExpirationMonths {
            let monthFormats = ["%02d", "%d"]
            for monthFormat in monthFormats {
                var candidates = expirations(months: month...month, monthFormat: monthFormat, year: "40")
                let match = sut.firstMatch(in: &candidates)
                #expect(match?.month == month && match?.year == 2040 && candidates.isEmpty)
            }
        }
    }

    @Test
    func firstMatch_whenValidCandidateContainsWhitespaces_matches() {
        // Given
        let sut = CardExpirationDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = ["01 /\t40"]

        // Then
        let match = sut.firstMatch(in: &candidates)
        #expect(match?.month == 1 && match?.year == 2040 && candidates.isEmpty)
    }

    @Test
    func firstMatch_whenMonthIsInvalid_doesNotMatch() {
        // Given
        let sut = CardExpirationDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = [
            ["0", "00"],
            expirations(months: 13...99, monthFormat: "%d", year: "40")
        ].flatMap { $0 }

        // Then
        print(candidates)
        #expect(sut.firstMatch(in: &candidates) == nil && candidates.count == 89)
    }

    @Test
    func firstMatch_whenDateIsInPast_matches() {
        // Given
        let sut = CardExpirationDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = ["01/01"]

        // Then
        let match = sut.firstMatch(in: &candidates)
        #expect(match?.month == 1 && match?.year == 2001 && match?.isExpired == true && candidates.isEmpty)
    }

    @Test
    func firstMatch_whenCandidatesContainsValidAndInvalidExpirations_matchesValid() {
        // Given
        let sut = CardExpirationDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = [
            "TEST", "04/40"
        ]

        // Then
        let match = sut.firstMatch(in: &candidates)
        #expect(match?.month == 4 && match?.year == 2040 && candidates == ["TEST"])
    }

    @Test
    func firstMatch_removesExpiredCandidates() {
        // Given
        let sut = CardExpirationDetector(regexProvider: .shared, formatter: .init())

        // When
        var candidates = [
            "01/01", "04/40", "02/02"
        ]

        // Then
        #expect(sut.firstMatch(in: &candidates) != nil && candidates.isEmpty)
    }

    // MARK: - Utils

    private func expirations(months: ClosedRange<Int>, monthFormat: String, year: String) -> [String] {
        months.map { String(format: monthFormat, $0) + "/" + year }
    }
}
