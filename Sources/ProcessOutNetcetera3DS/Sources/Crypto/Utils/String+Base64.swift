//
//  String+PaddedBase64.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.05.2025.
//

extension String {

    /// Returns the Base64 string with corrected padding.
    var base64WithFixedPadding: String {
        let paddingLength = (4 - count % 4) % 4
        return padding(toLength: count + paddingLength, withPad: "=", startingAt: 0)
    }
}
