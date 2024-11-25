//
//  CardExpirationDetector.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

import Foundation
@_spi(PO) import ProcessOut

struct CardExpirationDetector: CardAttributeDetector {

    init(regexProvider: PORegexProvider, formatter: POCardExpirationFormatter) {
        self.regexProvider = regexProvider
        self.formatter = formatter
        calendar = Calendar(identifier: .iso8601)
    }

    func firstMatch(in candidates: [String]) -> POScannedCard.Expiration? {
        guard let regex = regexProvider.regex(with: "(0[1-9]|1[0-2])[.\\/](\\d{4}|\\d{2})") else {
            return nil
        }
        for candidate in candidates {
            let candidate = candidate.removingCharacters(in: .whitespacesAndNewlines)
            let range = NSRange(candidate.startIndex..., in: candidate)
            guard let match = regex.firstMatch(in: candidate, range: range) else {
                continue
            }
            let monthDescription = candidate.substring(with: match.range(at: 1))
            let yearDescription = candidate.substring(with: match.range(at: 2))
            guard let month = Int(monthDescription), let year = Int(yearDescription).map(normalized(year:)) else {
                continue
            }
            guard isDateInFuture(month: month, year: year) else {
                continue
            }
            let description = formatter.string(from: String(month) + String(year % 100))
            return .init(month: month, year: year, description: description)
        }
        return nil
    }

    // MARK: - Private Properties

    private let regexProvider: PORegexProvider
    private let formatter: POCardExpirationFormatter
    private let calendar: Calendar

    // MARK: - Private Methods

    private func isDateInFuture(month: Int, year: Int) -> Bool {
        let currentDateComponents = calendar.dateComponents([.month, .year], from: Date())
        // swiftlint:disable force_unwrapping
        let currentMonth = currentDateComponents.month!
        let currentYear = currentDateComponents.year!
        // swiftlint:enable force_unwrapping
        return year > currentYear || (year == currentYear && month >= currentMonth)
    }

    private func normalized(year: Int) -> Int {
        guard year < 100 else {
            return year
        }
        // swiftlint:disable:next force_unwrapping
        let currentYear = calendar.dateComponents([.year], from: Date()).year!
        return (currentYear / 100) * 100 + year
    }
}
