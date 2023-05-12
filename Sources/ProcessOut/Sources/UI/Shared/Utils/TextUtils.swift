//
//  FormattingUtils.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.05.2023.
//

import Foundation

enum FormattingUtils {

    /// Returns index in formatted string that matches index in `string`.
    static func adjustedCursorOffset(
        in target: String,
        source: String,
        sourceCursorOffset: Int,
        ignoredCharacters: CharacterSet = [],
        greedy: Bool = true
    ) -> Int {
        let (sourceLhs, sourceRhs) = split(
            string: source, by: sourceCursorOffset, ignoring: ignoredCharacters
        )
        var targetOffset = target.count
        var minimumDistance = Int.max
        for offset in 0 ... target.count {
            let (targetLhs, targetRhs) = split(
                string: target, by: offset, ignoring: ignoredCharacters
            )
            let distance =
                editDistance(source: sourceLhs, target: targetLhs) +
                editDistance(source: sourceRhs, target: targetRhs)
            guard distance < minimumDistance || (greedy && distance == minimumDistance) else {
                continue
            }
            targetOffset = offset
            minimumDistance = distance
        }
        return targetOffset
    }

    // MARK: - Private Methods

    private static func split(
        string: String, by indexOffset: Int, ignoring ignoredCharacters: CharacterSet
    ) -> (String, String) {
        let index = string.index(string.startIndex, offsetBy: indexOffset)
        let lhs = string.prefix(upTo: index).removingCharacters(in: ignoredCharacters)
        let rhs = string.suffix(from: index).removingCharacters(in: ignoredCharacters)
        return (lhs, rhs)
    }

    /// Calculates minimum number of operations required to transform one string into the other.
    private static func editDistance(source: String, target: String) -> Int {
        if #available(iOS 13.0, *) {
            return target.difference(from: source).count
        }
        // Fallback to Levenshtein distance for iOS < 13
        var current  = Array(repeating: 0, count: target.count + 1)
        var previous = Array(0...target.count)
        for (sourceOffset, sourceCharacter) in source.enumerated() {
            current[0] = sourceOffset + 1
            for (targetOffset, targetCharacter) in target.enumerated() {
                var substitutionCost = previous[targetOffset]
                if sourceCharacter != targetCharacter {
                    substitutionCost += 1
                }
                current[targetOffset + 1] = min(
                    previous[targetOffset + 1] + 1, current[targetOffset] + 1, substitutionCost
                )
            }
            swap(&previous, &current)
        }
        return previous.last! // swiftlint:disable:this force_unwrapping
    }
}
