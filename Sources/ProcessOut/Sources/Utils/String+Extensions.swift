//
//  String+Extensions.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 09.03.2023.
//

import Foundation

extension String {

    /// A new string made from the string by removing all character in given `characterSet`.
    func removingCharacters(in characterSet: CharacterSet) -> String {
        String(String.UnicodeScalarView(unicodeScalars.filter(characterSet.inverted.contains)))
    }
}
