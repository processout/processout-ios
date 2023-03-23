//
//  PhoneNumberFormatter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

// swiftlint:disable:todo todo

import Foundation

final class PhoneNumberFormatter {

    init(metadataProvider: PhoneNumberMetadataProviderType = PhoneNumberMetadataProvider.shared) {
        regexProvider = RegexProvider.shared
        self.metadataProvider = metadataProvider
    }

    func format(partialNumber: String) -> String {
        var normalizedNumber = normalized(number: partialNumber)
        guard let metadata = extractMetadata(number: &normalizedNumber), !normalizedNumber.isEmpty else {
            return partialNumber
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

    // TODO(andrii-vysotskyi): migrate to `format(partialNumber:)`
    func formattedNumber(from string: String) -> String {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.isEmpty || trimmedString.prefix(1) == "+" {
            return string
        }
        return "+" + trimmedString
    }

    func normalized(number: String) -> String {
        number.removingCharacters(in: .decimalDigits.inverted)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let maxCountryPrefixLength = 3
        static let maxNationalNumberLength = 14
        static let placeholderNumber = "0"
    }

    // MARK: - Private Properties

    private let regexProvider: RegexProvider
    private let metadataProvider: PhoneNumberMetadataProviderType

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
        let nationalNumber = partialNationalNumber.appending(
            String(
                repeating: Constants.placeholderNumber,
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
            let formattedNumber = formatted(
                nationalNumber: nationalNumber, match: match, format: format, countryCode: countryCode
            )
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
        return String(cleanedNumber)
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
                return formatted(
                    nationalNumber: nationalNumber, match: match, format: format, countryCode: metadata.countryCode
                )
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

    private func formatted(
        nationalNumber: String, match: NSTextCheckingResult, format: PhoneNumberFormat, countryCode: String
    ) -> String {
        let groups = stride(from: 1, to: match.numberOfRanges, by: 1).map { index in
            let range = match.range(at: index)
            // swiftlint:disable:next legacy_objc_type
            return (nationalNumber as NSString).substring(with: range)
        }
        let formattedNationalNumber = String(format: format.format, arguments: groups) // avoid using printf
        return "+\(countryCode) \(formattedNationalNumber)"
    }
}
