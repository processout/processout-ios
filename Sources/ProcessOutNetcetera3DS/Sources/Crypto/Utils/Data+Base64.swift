//
//  Data+Base64.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

import Foundation

extension Data {

    /// Initialize a `Data` from a Base-64 URL encoded String.
    init?(base64UrlEncoded: String) {
        let base64Encoded = base64UrlEncoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            .base64WithFixedPadding
        self.init(base64Encoded: base64Encoded)
    }
}
