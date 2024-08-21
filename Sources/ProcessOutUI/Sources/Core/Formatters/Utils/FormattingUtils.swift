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
    /// Implementation of this method assumes that significant symbols after cursor are not modified otherwise
    /// it returns cursor positioned at the end of the `target` string. This approach has linear time complexity.
    ///
    /// Alternative solution would be to compare all substrings starting from end of `target` with suffix
    /// after cursor in `source` and finding substring with least possible difference (using for example Levenshtein
    /// distance). Downside of it would be almost cubic complexity.
    static func adjustedCursorOffset(
        in target: String,
        source: String,
        sourceCursorOffset: Int,
        significantCharacters: CharacterSet,
        greedy: Bool = true
    ) -> Int {
        let sourceSignificantSuffix = source
            .suffix(max(source.count - sourceCursorOffset, 0))
            .removingCharacters(in: significantCharacters.inverted)
        var targetOffset = target.count
        var targetSignificantSuffixLength = 0
        for (offset, character) in target.enumerated().reversed() {
            if character.unicodeScalars.allSatisfy(significantCharacters.contains) {
                if targetSignificantSuffixLength < sourceSignificantSuffix.count {
                    let sourceSignificantSuffixIndex = sourceSignificantSuffix.index(
                        sourceSignificantSuffix.endIndex,
                        offsetBy: -(targetSignificantSuffixLength + 1),
                        limitedBy: sourceSignificantSuffix.startIndex
                    )
                    guard let sourceSignificantSuffixIndex,
                          character == sourceSignificantSuffix[sourceSignificantSuffixIndex] else {
                        return target.count
                    }
                    targetOffset = offset
                    targetSignificantSuffixLength += 1
                } else {
                    return targetOffset
                }
            } else if !greedy {
                targetOffset = offset
            }
        }
        return targetOffset
    }
}
