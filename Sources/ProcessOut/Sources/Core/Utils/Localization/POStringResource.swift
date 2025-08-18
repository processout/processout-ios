//
//  POStringResource.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.01.2024.
//

import Foundation

@_spi(PO)
public struct POStringResource: Sendable {

    /// The key to use to look up a localized string.
    let key: String

    /// The bundle containing the table’s strings file.
    let bundle: Bundle

    public init(_ key: String, bundle: Bundle, comment: String) {
        self.key = key
        self.bundle = bundle
    }

    init(_ key: String, comment: String) {
        self.key = key
        self.bundle = BundleLocator.bundle
    }
}
