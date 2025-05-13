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

    func firstMatch(in candidates: inout [String]) -> POScannedCard.Expiration? {
        let regexPattern = "(?<!\\d)([1-9]|0[1-9]|1[0-2])\\s*[\\/.-]\\s*(\\d{4}|\\d{2})(?!\\d)"
        guard let regex = regexProvider.regex(with: regexPattern) else {
            return nil
        }
        var matchedExpirations: [POScannedCard.Expiration] = []
        for (offset, candidate) in candidates.enumerated().reversed() {
            let range = NSRange(candidate.startIndex..., in: candidate)
            var didMatchExpiration = false
            regex.enumerateMatches(in: candidate, range: range) { match, _, _ in
                guard let match else {
                    return
                }
                let monthDescription = candidate.substring(with: match.range(at: 1))
                let yearDescription = candidate.substring(with: match.range(at: 2))
                guard let month = Int(monthDescription), let year = Int(yearDescription).map(normalized(year:)) else {
                    return
                }
                let isExpired = !isDateInFuture(month: month, year: year)
                let description = formatter.string(from: String(month) + String(year % 100))
                matchedExpirations.append(
                    .init(month: month, year: year, isExpired: isExpired, description: description)
                )
                didMatchExpiration = true
            }
            if didMatchExpiration {
                candidates.remove(at: offset)
            }
        }
        return matchedExpirations.max { $0.year < $1.year || ($0.year == $1.year && $0.month < $1.month) }
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
