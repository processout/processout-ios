//
//  FormattingUtils.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.05.2023.
//

import Foundation

enum FormattingUtils {

    /// Returns index in formatted string that matches index in `string`.
    ///
    /// Implementation of this method assumes that significant symbols before cursor are not modified otherwise
    /// it returns cursor positioned at the end of the `target` string. This approach has linear time complexity.
    ///
    /// Alternative solution would be to compare all substrings starting from beginning of `target` with prefix
    /// before cursor in `source` and finding substring with least possible difference (using for example Levenshtein
    /// distance). Downside of it would be almost cubic complexity.
    static func adjustedCursorOffset(
        in target: String,
        source: String,
        sourceCursorOffset: Int,
        significantCharacters: CharacterSet,
        greedy: Bool = true
    ) -> Int {
        let sourceSignificantPrefix = source
            .prefix(sourceCursorOffset)
            .removingCharacters(in: significantCharacters.inverted)
        var targetOffset = 0
        var targetSignificantPrefixLength = 0
        for (offset, character) in target.enumerated() {
            if character.unicodeScalars.allSatisfy(significantCharacters.contains) {
                if targetSignificantPrefixLength < sourceSignificantPrefix.count {
                    let sourceSignificantPrefixIndex = sourceSignificantPrefix.index(
                        sourceSignificantPrefix.startIndex,
                        offsetBy: targetSignificantPrefixLength,
                        limitedBy: sourceSignificantPrefix.endIndex
                    )
                    guard let sourceSignificantPrefixIndex,
                          character == sourceSignificantPrefix[sourceSignificantPrefixIndex] else {
                        return target.count
                    }
                    targetOffset = offset + 1
                    targetSignificantPrefixLength += 1
                } else {
                    return targetOffset
                }
            } else if greedy {
                targetOffset = offset + 1
            }
        }
        return targetOffset
    }
}
