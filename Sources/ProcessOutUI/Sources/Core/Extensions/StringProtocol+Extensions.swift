//
//  StringProtocol+Extensions.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 09.03.2023.
//

import Foundation

extension StringProtocol {

    /// A new string made from the string by removing all character in given `characterSet`.
    func removingCharacters(in characterSet: CharacterSet) -> String {
        String(String.UnicodeScalarView(unicodeScalars.filter(characterSet.inverted.contains)))
    }

    func trimmingSuffixCharacters(in characterSet: CharacterSet) -> String {
        var trimmedSuffixLength = 0
        var iterator = reversed().makeIterator()
        while let character = iterator.next(), character.unicodeScalars.allSatisfy(characterSet.contains) {
            trimmedSuffixLength += 1
        }
        return String(dropLast(trimmedSuffixLength))
    }
}
