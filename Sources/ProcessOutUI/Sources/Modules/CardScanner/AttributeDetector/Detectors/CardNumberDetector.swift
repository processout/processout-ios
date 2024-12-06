//
//  CardNumberDetector.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

import Foundation
@_spi(PO) import ProcessOut

struct CardNumberDetector: CardAttributeDetector {

    init(regexProvider: PORegexProvider, formatter: POCardNumberFormatter) {
        self.regexProvider = regexProvider
        self.formatter = formatter
    }

    func firstMatch(in candidates: inout [String]) -> String? {
        guard let numberRegex = regexProvider.regex(with: "(?:\\d\\s*){12,19}") else {
            return nil
        }
        for (offset, candidate) in candidates.enumerated() {
            let range = NSRange(candidate.startIndex..., in: candidate)
            guard let match = numberRegex.firstMatch(in: candidate, range: range) else {
                continue
            }
            let number = candidate.substring(with: match.range).filter { !$0.isWhitespace }
            guard isLengthValid(number: number), isChecksumValid(number: number) else {
                continue
            }
            candidates.remove(at: offset)
            return formatter.string(from: number)
        }
        return nil
    }

    // MARK: - Private Properties

    private let regexProvider: PORegexProvider
    private let formatter: POCardNumberFormatter

    // MARK: - Private Methods

    private func isLengthValid(number: String) -> Bool {
        number.count >= 12 && number.count <= 19
    }

    private func isChecksumValid(number: String) -> Bool {
        var checkDigit = 0
        for (offset, character) in number.reversed().enumerated().dropFirst() {
            guard let digit = character.wholeNumberValue else {
                return false
            }
            if offset % 2 == 0 {
                checkDigit += digit
            } else if digit > 4 {
                checkDigit += digit * 2 - 9
            } else {
                checkDigit += digit * 2
            }
        }
        return 10 - (checkDigit % 10) == number.last?.wholeNumberValue
    }
}
