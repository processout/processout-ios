//
//  CardNumberFormatter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.07.2023.
//

import Foundation

final class CardNumberFormatter: Formatter {

    func string(from partialNumber: String) -> String {
        let normalizedNumber = normalized(number: partialNumber).prefix(Constants.maxLength)
        for format in formats {
            if let formattedNumber = attemptToFormat(cardNumber: normalizedNumber, format: format) {
                return formattedNumber
            }
        }
        return attemptToFormat(cardNumber: normalizedNumber, pattern: Constants.defaultPattern) ?? partialNumber
    }

    func normalized(number: String) -> String {
        number.removingCharacters(in: Constants.significantCharacters.inverted)
    }

    // MARK: - Formatter

    override func string(for obj: Any?) -> String? {
        guard let cardNumber = obj as? String else {
            return nil
        }
        return string(from: cardNumber)
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

    private struct PaymentCardNumberFormat {
        let leading: [ClosedRange<Int>]
        let patterns: [String]
    }

    private enum Constants {
        static let significantCharacters = CharacterSet.decimalDigits
        static let maxLength = 19 // Maximum PAN length based on ISO/IEC 7812
        static let placeholderCharacter: Character = "#"
        static let defaultPattern = "#### #### #### #### ###"
    }

    // MARK: - Private Properties

    // Reference: https://baymard.com/blog/credit-card-field-auto-format-spaces
    private let formats: [PaymentCardNumberFormat] = [
        .init(leading: [34...34, 37...37], patterns: ["#### ###### #####"]),
        .init(leading: [62...62], patterns: ["#### #### #### ####", "###### #############"]),
        .init(
            leading: [500000...509999, 560000...589999, 600000...699999],
            patterns: ["#### #### #####", "#### ###### #####", "#### #### #### ####", "#### #### #### #### ###"]
        ),
        .init(leading: [300...305, 309...309, 36...36, 38...39], patterns: ["#### ###### ####"]),
        .init(leading: [1...1], patterns: ["#### ##### ######"])
    ]

    // MARK: - Private Methods

    private func attemptToFormat(cardNumber: any StringProtocol, format: PaymentCardNumberFormat) -> String? {
        for acceptableLeading in format.leading {
            // Range's upper and lower bounds are expected to be of the same length.
            let leadingDescription = cardNumber.prefix(acceptableLeading.upperBound.description.count)
            guard let leading = Int(leadingDescription), acceptableLeading.contains(leading) else {
                continue
            }
            for pattern in format.patterns {
                if let formattedNumber = attemptToFormat(cardNumber: cardNumber, pattern: pattern) {
                    return formattedNumber
                }
            }
        }
        return nil
    }

    private func attemptToFormat(cardNumber: any StringProtocol, pattern: String) -> String? {
        var formattedNumber = ""
        var cardNumberIndex = cardNumber.startIndex
        for character in pattern where cardNumberIndex < cardNumber.endIndex {
            if character == Constants.placeholderCharacter {
                formattedNumber.append(cardNumber[cardNumberIndex])
                cardNumberIndex = cardNumber.index(after: cardNumberIndex)
            } else {
                formattedNumber.append(character)
            }
        }
        guard cardNumberIndex == cardNumber.endIndex else {
            return nil // Pattern is too short
        }
        return formattedNumber.applyingTransform(.toLatin, reverse: false) ?? formattedNumber
    }
}
