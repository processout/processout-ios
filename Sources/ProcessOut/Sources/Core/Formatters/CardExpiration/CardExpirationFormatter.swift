//
//  CardExpirationFormatter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.07.2023.
//

import Foundation

final class CardExpirationFormatter: Formatter {

    init(metadataProvider: PhoneNumberMetadataProvider = DefaultPhoneNumberMetadataProvider.shared) {
        regexProvider = RegexProvider.shared
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func string(from expiration: String) -> String {
        let normalizedExpiration = normalized(expiration: expiration)
        guard !normalizedExpiration.isEmpty else {
            return ""
        }
        guard let regex = regexProvider.regex(with: Constants.pattern) else {
            assertionFailure("Unable to create regex to parse expiration date components.")
            return expiration
        }
        let range = NSRange(normalizedExpiration.startIndex ..< normalizedExpiration.endIndex, in: normalizedExpiration)
        guard let match = regex.firstMatch(in: normalizedExpiration, options: .anchored, range: range) else {
            assertionFailure("Unexpected matching failure.")
            return ""
        }
        let month = normalizedExpiration.substring(with: match.range(at: 1))
        let year = normalizedExpiration.substring(with: match.range(at: 2))
        return formatted(month: month, year: year)
    }

    // MARK: - Formatter

    override func string(for obj: Any?) -> String? {
        guard let phoneNumber = obj as? String else {
            return nil
        }
        return string(from: phoneNumber)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let significantCharacters = CharacterSet.decimalDigits
        static let pattern = "^(0+[1-9]|1[0-2]{0,1}|[2-9])([0-9]{0,2})"
        static let separator = " / "
        static let monthLength = 2
    }

    // MARK: - Private Properties

    private let regexProvider: RegexProvider

    // MARK: - Private Methods

    private func normalized(expiration: String) -> String {
        expiration.removingCharacters(in: Constants.significantCharacters.inverted)
    }

    private func formatted(month: String, year: String) -> String {
        var expiration = ""
        let paddedMonth = padded(month: month, force: !year.isEmpty)
        expiration += paddedMonth
        if paddedMonth.count == Constants.monthLength {
            expiration.append(Constants.separator)
        }
        expiration += year
        return expiration.applyingTransform(.toLatin, reverse: false) ?? expiration
    }

    private func padded(month: String, force: Bool) -> String {
        guard month.count == 1, let monthValue = Int(month) else {
            return month
        }
        guard force || (monthValue > 1 && monthValue < 10) else {
            return month
        }
        return String(repeating: "0", count: Constants.monthLength - month.count) + month
    }
}
