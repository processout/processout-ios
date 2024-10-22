//
//  POButtonRole.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2024.
//

/// A value that describes the purpose of a button.
@_spi(PO)
public struct POButtonRole: RawRepresentable, Sendable, Hashable {

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension POButtonRole {

    /// The button is the default button — the button people are most likely to choose.
    public static let primary = POButtonRole(rawValue: "Primary")

    /// The button cancels the current action.
    public static let cancel = POButtonRole(rawValue: "Cancel")
}
