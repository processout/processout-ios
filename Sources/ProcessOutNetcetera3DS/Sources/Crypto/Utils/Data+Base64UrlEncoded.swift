//
//  Data+Base64UrlEncoded.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

import Foundation

extension Data {

    /// Initialize a `Data` from a Base-64 URL encoded String.
    init?(base64UrlEncoded: String) {
        let paddingLength = (4 - base64UrlEncoded.count % 4) % 4
        let base64Encoded = base64UrlEncoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            .padding(toLength: base64UrlEncoded.count + paddingLength, withPad: "=", startingAt: 0)
        self.init(base64Encoded: base64Encoded)
    }
}
