//
//  POCardExpirationFormatter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.07.2023.
//

import Foundation

@_spi(PO)
public final class POCardExpirationFormatter: Formatter {

    override public init() {
        regexProvider = RegexProvider.shared
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Returns formatted version of given expiration string.
    public func string(from string: String) -> String {
        let expiration = self.expiration(from: string)
        guard !expiration.month.isEmpty else {
            return ""
        }
        return formatted(month: expiration.month, year: expiration.year)
    }

    public func expirationMonth(from string: String) -> Int? {
        let monthDescription = expiration(from: string).month
        guard let month = Int(monthDescription), month > 0, month <= 12 else {
            return nil
        }
        return month
    }

    public func expirationYear(from string: String) -> Int? {
        let yearDescription = expiration(from: string).year
        return Int(yearDescription)
    }

    // MARK: - Formatter

    override public func string(for obj: Any?) -> String? {
        guard let expiration = obj as? String else {
            return nil
        }
        return string(from: expiration)
    }

    override public func isPartialStringValid(
        _ partialStringPtr: AutoreleasingUnsafeMutablePointer<NSString>, // swiftlint:disable:this legacy_objc_type
        proposedSelectedRange proposedSelRangePtr: NSRangePointer?,
        originalString origString: String,
        originalSelectedRange origSelRange: NSRange,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>? // swiftlint:disable:this legacy_objc_type
    ) -> Bool {
        let partialString = partialStringPtr.pointee as String
        let formatted = string(from: partialString)
        let adjustedOffset = POFormattingUtils.adjustedCursorOffset(
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

    private struct Expiration {
        let month, year: String
    }

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
        guard let monthValue = Int(month) else {
            assertionFailure("Month should be valid integer.")
            return month
        }
        guard monthValue != 0 else {
            return "0"
        }
        let isPadded = month.first == "0"
        guard forcePadding || (monthValue > 1 && monthValue < 10) || isPadded else {
            return monthValue.description
        }
        let monthValueDescription = String(monthValue)
        let paddingLength = max(Constants.monthLength - monthValueDescription.count, 0)
        return String(repeating: "0", count: paddingLength) + monthValueDescription
    }

    // MARK: -

    private func expiration(from string: String) -> Expiration {
        let normalizedString = normalized(expiration: string)
        guard !normalizedString.isEmpty else {
            return Expiration(month: "", year: "")
        }
        let range = NSRange(normalizedString.startIndex ..< normalizedString.endIndex, in: normalizedString)
        guard let regex = regexProvider.regex(with: Constants.pattern),
              let match = regex.firstMatch(in: normalizedString, options: .anchored, range: range) else {
            assertionFailure("Unexpected matching failure.")
            return Expiration(month: "", year: "")
        }
        let month = normalizedString.substring(with: match.range(at: 1))
        let year = normalizedString.substring(with: match.range(at: 2))
        return Expiration(month: month, year: year)
    }
}
