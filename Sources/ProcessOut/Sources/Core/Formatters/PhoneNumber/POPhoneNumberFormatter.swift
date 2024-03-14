//
//  POPhoneNumberFormatter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

import Foundation

@_spi(PO) public final class POPhoneNumberFormatter: Formatter {

    public init(metadataProvider: POPhoneNumberMetadataProvider = PODefaultPhoneNumberMetadataProvider.shared) {
        regexProvider = RegexProvider.shared
        self.metadataProvider = metadataProvider
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func string(from partialNumber: String) -> String {
        let normalizedNumber = normalized(number: partialNumber)
        guard !normalizedNumber.isEmpty else {
            return ""
        }
        var number = normalizedNumber.removingCharacters(in: Constants.significantCharactersWithoutPlus.inverted)
        guard let metadata = extractMetadata(number: &number) else {
            return formatted(countryCode: number, formattedNationalNumber: "")
        }
        // swiftlint:disable:next line_length
        guard number.count <= min(Constants.maxNationalNumberLength, Constants.maxNumberLength - metadata.countryCode.count),
              !number.isEmpty else {
            return formatted(countryCode: metadata.countryCode, formattedNationalNumber: number)
        }
        var potentialFormats: [POPhoneNumberFormat] = []
        if let formatted = attemptToFormat(
            nationalNumber: number, metadata: metadata, potentialFormats: &potentialFormats
        ) {
            return formatted
        }
        // Implementation failed to format national number. This may be caused by number being only
        // partial so attempting to format number as partial instead.
        if let formatted = attemptToFormat(
            partialNationalNumber: number, formats: potentialFormats, countryCode: metadata.countryCode
        ) {
            return formatted
        }
        return formatted(countryCode: metadata.countryCode, formattedNationalNumber: number)
    }

    public func normalized(number: String) -> String {
        number.removingCharacters(in: Constants.significantCharacters.inverted)
    }

    // MARK: - Formatter

    override public func string(for obj: Any?) -> String? {
        guard let phoneNumber = obj as? String else {
            return nil
        }
        return string(from: phoneNumber)
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

    private enum Constants {
        static let significantCharacters = CharacterSet(charactersIn: "+").union(.decimalDigits)
        static let significantCharactersWithoutPlus = CharacterSet.decimalDigits
        static let maxCountryPrefixLength = 3
        static let maxNationalNumberLength = 14
        static let maxNumberLength = 15
        static let placeholderDigit = "0"
        static let plus = "+"
        static let countryCodeSeparator = " "
    }

    // MARK: - Private Properties

    private let regexProvider: RegexProvider
    private let metadataProvider: POPhoneNumberMetadataProvider

    // MARK: - Full National Number Formatting

    private func attemptToFormat(
        nationalNumber: String, metadata: POPhoneNumberMetadata, potentialFormats: inout [POPhoneNumberFormat]
    ) -> String? {
        let range = NSRange(nationalNumber.startIndex ..< nationalNumber.endIndex, in: nationalNumber)
        for format in metadata.formats {
            guard shouldAttemptUsing(format: format, nationalNumber: nationalNumber, range: range),
                  let regex = regexProvider.regex(with: format.pattern) else {
                continue
            }
            if let match = regex.firstMatch(in: nationalNumber, options: .anchored, range: range),
               match.range == range {
                return formatted(nationalNumber: nationalNumber, countryCode: metadata.countryCode, format: format)
            }
            potentialFormats.append(format)
        }
        return nil
    }

    private func shouldAttemptUsing(format: POPhoneNumberFormat, nationalNumber: String, range: NSRange) -> Bool {
        for pattern in format.leading {
            guard let regex = regexProvider.regex(with: pattern) else {
                continue
            }
            if regex.firstMatch(in: nationalNumber, options: .anchored, range: range) != nil {
                return true
            }
        }
        return false
    }

    private func formatted(nationalNumber: String, countryCode: String, format: POPhoneNumberFormat) -> String {
        let formattedNationalNumber: String
        if let formatRegex = regexProvider.regex(with: format.pattern) {
            let range = NSRange(nationalNumber.startIndex ..< nationalNumber.endIndex, in: nationalNumber)
            formattedNationalNumber = formatRegex.stringByReplacingMatches(
                in: nationalNumber, range: range, withTemplate: format.format
            )
        } else {
            formattedNationalNumber = nationalNumber
        }
        return formatted(countryCode: countryCode, formattedNationalNumber: formattedNationalNumber)
    }

    // MARK: - Partial National Number Formatting

    private func attemptToFormat(
        partialNationalNumber: String, formats: [POPhoneNumberFormat], countryCode: String
    ) -> String? {
        let nationalNumber = partialNationalNumber.appending(
            String(
                repeating: Constants.placeholderDigit,
                count: Constants.maxNationalNumberLength - partialNationalNumber.count
            )
        )
        let range = NSRange(nationalNumber.startIndex ..< nationalNumber.endIndex, in: nationalNumber)
        for format in formats {
            guard let regex = regexProvider.regex(with: format.pattern),
                  let match = regex.firstMatch(in: nationalNumber, options: .anchored, range: range),
                  match.range.length >= partialNationalNumber.count else {
                continue
            }
            let formattedNumber = formatted(nationalNumber: nationalNumber, countryCode: countryCode, format: format)
            return removingPlaceholderSuffix(
                number: formattedNumber, expectedSignificantLength: partialNationalNumber.count + countryCode.count
            )
        }
        return nil
    }

    private func removingPlaceholderSuffix(number: String, expectedSignificantLength: Int) -> String {
        var significantDigitsCount = 0
        let cleanedNumber = number.prefix { character in
            if character.isNumber {
                significantDigitsCount += 1
            }
            return significantDigitsCount <= expectedSignificantLength
        }
        return String(cleanedNumber).trimmingSuffixCharacters(in: Constants.significantCharacters.inverted)
    }

    // MARK: - Utils

    private func extractMetadata(number: inout String) -> POPhoneNumberMetadata? {
        let length = min(Constants.maxCountryPrefixLength, number.count)
        for i in stride(from: 1, through: length, by: 1) { // swiftlint:disable:this identifier_name
            let potentialCountryCode = String(number.prefix(i))
            if let metadata = metadataProvider.metadata(for: potentialCountryCode) {
                number.removeFirst(i)
                return metadata
            }
        }
        return nil
    }

    private func formatted(countryCode: String, formattedNationalNumber number: String) -> String {
        var formattedNumber: String = "\(Constants.plus)\(countryCode)"
        if !number.isEmpty {
            formattedNumber += "\(Constants.countryCodeSeparator)\(number)"
        }
        // Formatted phone numbers are always converted to latin script for simplicity.
        return formattedNumber.applyingTransform(.toLatin, reverse: false) ?? formattedNumber
    }
}
