//
//  CardSecurityCodeFormatter.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 10.11.2023.
//

import Foundation
@_spi(PO) import ProcessOut

final class CardSecurityCodeFormatter: Formatter {

    /// Card scheme.
    var scheme: String?

    /// Returns formatted version of given cvc string.
    func string(from string: String) -> String {
        // When scheme is not available or unknown we assume that CSC could be up to 4 digits.
        let length = scheme.flatMap { Self.lengths[$0] } ?? 4
        let formatted = string
            .removingCharacters(in: CharacterSet.decimalDigits.inverted)
            .prefix(length)
        return String(formatted)
    }

    // MARK: - Formatter

    override func string(for obj: Any?) -> String? {
        guard let cvc = obj as? String else {
            return nil
        }
        return string(from: cvc)
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
        let adjustedOffset = POFormattingUtils.adjustedCursorOffset(
            in: formatted,
            source: partialString,
            // swiftlint:disable:next line_length
            sourceCursorOffset: origSelRange.lowerBound + origSelRange.length + (partialString.count - origString.count),
            significantCharacters: CharacterSet.decimalDigits,
            greedy: partialString.count >= origString.count
        )
        partialStringPtr.pointee = formatted as NSString // swiftlint:disable:this legacy_objc_type
        proposedSelRangePtr?.pointee = NSRange(location: adjustedOffset, length: 0)
        return true
    }

    // MARK: - Private Properties

    private static let lengths: [String: Int] = [
        "american express": 4,
        "visa": 3,
        "mastercard": 3,
        "jcb": 3,
        "discover": 3,
        "diners club": 3,
        "diners club carte blanche": 3,
        "diners club international": 3,
        "diners club united states & canada": 3,
        "nspk mir": 3,
        "china union pay": 3,
        "elo": 3,
        "vpay": 3,
        "mada": 3,
        "rupay": 3,
        "switch": 3
    ]
}
