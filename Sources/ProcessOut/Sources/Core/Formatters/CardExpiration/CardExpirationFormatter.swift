//
//  CardExpirationFormatter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.07.2023.
//

import Foundation

final class CardExpirationFormatter: Formatter {

    override init() {
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

    override func isPartialStringValid(
        _ partialStringPtr: AutoreleasingUnsafeMutablePointer<NSString>, // swiftlint:disable:this legacy_objc_type
        proposedSelectedRange proposedSelRangePtr: NSRangePointer?,
        originalString origString: String,
        originalSelectedRange origSelRange: NSRange,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>? // swiftlint:disable:this legacy_objc_type
    ) -> Bool {
        let partialString = partialStringPtr.pointee as String
        let formatted = string(from: partialString)
        let adjustedOffset = FormattingUtils.adjustedCursorOffset(
            in: formatted,
            source: partialString,
            // swiftlint:disable:next line_length
            sourceCursorOffset: origSelRange.lowerBound + origSelRange.length + (partialString.count - origString.count),
            significantCharacters: Constants.significantCharacters,
            greedy: partialString.count >= origString.count
        )
        partialStringPtr.pointee = formatted as NSString // swiftlint:disable:this legacy_objc_type
        proposedSelRangePtr?.pointee = NSRange(location: adjustedOffset, length: 0)
        return true
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let significantCharacters = CharacterSet.decimalDigits
        static let pattern = "^(0+$|0+[1-9]|1[0-2]{0,1}|[2-9])([0-9]{0,2})"
        static let separator = " / "
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
        let formattedMonth = formatted(month: month, forcePadding: !year.isEmpty)
        expiration += formattedMonth
        if formattedMonth.count == Constants.monthLength {
            expiration.append(Constants.separator)
        }
        expiration += year
        return expiration.applyingTransform(.toLatin, reverse: false) ?? expiration
    }

    private func formatted(month: String, forcePadding: Bool) -> String {
        if month.isEmpty {
            return ""
        }
        guard let monthValue = Int(month) else {
            assertionFailure("Month should be valid integer or empty.")
            return month
        }
        guard monthValue != 0 else {
            return "0"
        }
        let isPadded = month.first == "0"
        guard forcePadding || (monthValue > 1 && monthValue < 10) || isPadded else {
            return monthValue.description
        }
        let paddingLength = max(Constants.monthLength - month.count, 0)
        return String(repeating: "0", count: paddingLength) + month
    }
}
