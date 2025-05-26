//
//  PhoneNumber.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.05.2025.
//

/// Phone number.
@_spi(PO)
public struct POPhoneNumber: Sendable {

    public struct Territory: Identifiable, Hashable, Sendable {

        /// Country ID.
        public let id: String

        /// Country display name.
        public let displayName: String

        /// E.164 code.
        public let code: String

        public init(id: String, displayName: String, code: String) {
            self.id = id
            self.displayName = displayName
            self.code = code
        }
    }

    /// Currently selected territory ID.
    public var territoryId: String?

    /// Local phone number.
    public var number: String

    public init(territoryId: String? = nil, number: String) {
        self.territoryId = territoryId
        self.number = number
    }
}
