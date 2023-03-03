//
//  PhoneNumberFormatter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.02.2023.
//

import Foundation

final class PhoneNumberFormatter {

    func formattedNumber(from string: String) -> String {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.isEmpty || trimmedString.prefix(1) == "+" {
            return string
        }
        return "+" + trimmedString
    }
}
