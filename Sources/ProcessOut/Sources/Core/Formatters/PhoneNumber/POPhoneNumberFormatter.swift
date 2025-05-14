//
//  POPhoneNumberFormatter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

import Foundation

@_spi(PO)
public final class POPhoneNumberFormatter: Formatter {

    /// Number original assumption.
    public enum OriginAssumption {

        /// Implementation assumes that input number is international even if it
        /// doesn't have + prefix.
        case international

        /// Implementation assumes that input number is national even if it has +
        /// prefix.
        case national
    }

    public init(parser: POPhoneNumberParser = .shared) {
        regexProvider = .shared
        self.parser = parser
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Default dial code.
    public var defaultRegion: String?

    /// Boolean value indicating whether when implementation should format number in international
    /// format when possible.
    public var preferInternationalFormat = true

    /// Phone number origin context.
    public var originAssumption: OriginAssumption? = .international // For backward compatibility

    // MARK: -

    public func string(from partialNumber: String) -> String {
        var normalizedPartialNumber = normalized(number: partialNumber)
        apply(assumption: originAssumption, to: &normalizedPartialNumber)
        let phoneNumber = parser.parse(
            number: normalizedPartialNumber, defaultRegion: defaultRegion
        )
        guard let phoneNumber else {
            return parser.normalize(number: normalizedPartialNumber)
        }
        var potentialFormats: [POPhoneNumberMetadata.Format] = []
        // todo(andrii-vysotskyi): attempt to format as partial immediately for simplicity.
        let formattedNationalNumber =
            attemptToFormat(
                nationalNumber: phoneNumber.national,
                metadata: phoneNumber.metadata,
                potentialFormats: &potentialFormats
            ) ??
            // Implementation failed to format national number. This may be caused by number being only
            // partial or too long.
            attemptToFormat(partialNationalNumber: phoneNumber.national, formats: potentialFormats)
        guard preferInternationalFormat else {
            return formattedNationalNumber ?? phoneNumber.national
        }
        return formatToInternational(
            nationalNumber: formattedNationalNumber ?? phoneNumber.national, countryCode: phoneNumber.countryCode
        )
    }

    public func normalized(number: String) -> String {
        parser.normalize(number: number)
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
        static let maxNationalNumberLength = 14
        static let placeholderDigit = "0"
        static let plus = "+"
        static let countryCodeSeparator = " "
    }

    // MARK: - Private Properties

    private let regexProvider: PORegexProvider
    private let parser: POPhoneNumberParser

    // MARK: - Full National Number Formatting

    private func attemptToFormat(
        nationalNumber: String,
        metadata: [POPhoneNumberMetadata],
        potentialFormats: inout [POPhoneNumberMetadata.Format]
    ) -> String? {
        let range = NSRange(nationalNumber.startIndex ..< nationalNumber.endIndex, in: nationalNumber)
        for format in metadata.flatMap(\.formats) {
            guard shouldAttemptUsing(format: format, nationalNumber: nationalNumber, range: range),
                  let regex = regexProvider.regex(with: format.pattern) else {
                continue
            }
            if let match = regex.firstMatch(in: nationalNumber, options: .anchored, range: range),
               match.range == range {
                return formatted(nationalNumber: nationalNumber, format: format)
            }
            potentialFormats.append(format)
        }
        return nil
    }

    private func shouldAttemptUsing(
        format: POPhoneNumberMetadata.Format, nationalNumber: String, range: NSRange
    ) -> Bool {
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

    private func formatted(nationalNumber: String, format: POPhoneNumberMetadata.Format) -> String {
        let formattedNationalNumber: String
        if let formatRegex = regexProvider.regex(with: format.pattern) {
            let range = NSRange(nationalNumber.startIndex ..< nationalNumber.endIndex, in: nationalNumber)
            formattedNationalNumber = formatRegex.stringByReplacingMatches(
                in: nationalNumber, range: range, withTemplate: format.format
            )
        } else {
            formattedNationalNumber = nationalNumber
        }
        return formattedNationalNumber
    }

    // MARK: - Partial National Number Formatting

    private func attemptToFormat(partialNationalNumber: String, formats: [POPhoneNumberMetadata.Format]) -> String? {
        let nationalNumber = partialNationalNumber.appending(
            String(
                repeating: Constants.placeholderDigit,
                count: max(Constants.maxNationalNumberLength - partialNationalNumber.count, 0)
            )
        )
        let range = NSRange(nationalNumber.startIndex ..< nationalNumber.endIndex, in: nationalNumber)
        for format in formats {
            guard let regex = regexProvider.regex(with: format.pattern),
                  let match = regex.firstMatch(in: nationalNumber, options: .anchored, range: range),
                  match.range.length >= partialNationalNumber.count else {
                continue
            }
            let formattedNumber = formatted(nationalNumber: nationalNumber, format: format)
            return removingPlaceholderSuffix(
                number: formattedNumber, expectedSignificantLength: partialNationalNumber.count
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

    private func formatToInternational(nationalNumber: String, countryCode: String) -> String {
        var formattedNumber = "\(Constants.plus)\(countryCode)"
        if !nationalNumber.isEmpty {
            formattedNumber.append(Constants.countryCodeSeparator)
            formattedNumber.append(nationalNumber)
        }
        return formattedNumber
    }

    private func apply(assumption: OriginAssumption?, to number: inout String) {
        switch assumption {
        case .international where !number.hasPrefix(Constants.plus) && !number.isEmpty:
            number.insert(contentsOf: Constants.plus, at: number.startIndex)
        case .national where number.hasPrefix(Constants.plus):
            number.removeFirst(1)
        default:
            break
        }
    }
}
