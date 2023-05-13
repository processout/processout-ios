//
//  PhoneNumberFormatter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

import Foundation

final class PhoneNumberFormatter {

    init(metadataProvider: PhoneNumberMetadataProvider = DefaultPhoneNumberMetadataProvider.shared) {
        regexProvider = RegexProvider.shared
        self.metadataProvider = metadataProvider
    }

    func format(partialNumber: String) -> String {
        guard !partialNumber.isEmpty else {
            return partialNumber
        }
        var normalizedNumber = normalized(number: partialNumber)
        guard let metadata = extractMetadata(number: &normalizedNumber) else {
            return "\(Constants.plus)\(normalizedNumber)"
        }
        guard !normalizedNumber.isEmpty else {
            return "\(Constants.plus)\(metadata.countryCode)"
        }
        var potentialFormats: [PhoneNumberFormat] = []
        if let formatted = attemptToFormat(
            nationalNumber: normalizedNumber, metadata: metadata, potentialFormats: &potentialFormats
        ) {
            return formatted
        }
        // Implementation failed to format national number. This may be caused by number being only
        // partial so attempting to format number as partial instead.
        if let formatted = attemptToFormat(
            partialNationalNumber: normalizedNumber, formats: potentialFormats, countryCode: metadata.countryCode
        ) {
            return formatted
        }
        return partialNumber
    }

    func normalized(number: String) -> String {
        number.removingCharacters(in: Constants.significantCharacters.inverted)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let significantCharacters = CharacterSet.decimalDigits
        static let maxCountryPrefixLength = 3
        static let maxNationalNumberLength = 14
        static let placeholderDigit = "0"
        static let plus = "+"
    }

    // MARK: - Private Properties

    private let regexProvider: RegexProvider
    private let metadataProvider: PhoneNumberMetadataProvider

    // MARK: - Private Methods

    private func extractMetadata(number: inout String) -> PhoneNumberMetadata? {
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

    private func attemptToFormat(
        partialNationalNumber: String, formats: [PhoneNumberFormat], countryCode: String
    ) -> String? {
        guard partialNationalNumber.count <= Constants.maxNationalNumberLength else {
            return nil
        }
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

    private func attemptToFormat(
        nationalNumber: String, metadata: PhoneNumberMetadata, potentialFormats: inout [PhoneNumberFormat]
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

    private func shouldAttemptUsing(format: PhoneNumberFormat, nationalNumber: String, range: NSRange) -> Bool {
        for pattern in format.leadingDigits {
            guard let regex = regexProvider.regex(with: pattern) else {
                continue
            }
            if regex.firstMatch(in: nationalNumber, options: .anchored, range: range) != nil {
                return true
            }
        }
        return false
    }

    private func formatted(nationalNumber: String, countryCode: String, format: PhoneNumberFormat) -> String {
        let formattedNationalNumber: String
        if let formatRegex = regexProvider.regex(with: format.pattern) {
            let range = NSRange(nationalNumber.startIndex ..< nationalNumber.endIndex, in: nationalNumber)
            formattedNationalNumber = formatRegex.stringByReplacingMatches(
                in: nationalNumber, range: range, withTemplate: format.format
            )
        } else {
            formattedNationalNumber = nationalNumber
        }
        return "\(Constants.plus)\(countryCode) \(formattedNationalNumber)"
    }
}
