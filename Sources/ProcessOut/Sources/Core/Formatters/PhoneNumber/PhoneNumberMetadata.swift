//
//  PhoneNumberMetadata.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

struct PhoneNumberMetadata: Decodable {

    /// Country code.
    let countryCode: String

    /// Available formats.
    let formats: [PhoneNumberFormat]
}
