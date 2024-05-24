//
//  PhoneNumberFormat.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

struct PhoneNumberFormat: Decodable {

    /// Formatting pattern.
    let pattern: String

    /// Leading digits pattern.
    let leading: [String]

    /// Format to use for number.
    let format: String
}
