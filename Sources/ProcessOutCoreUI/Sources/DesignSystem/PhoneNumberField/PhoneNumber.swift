//
//  PhoneNumber.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.05.2025.
//

/// Phone number.
@_spi(PO)
public struct POPhoneNumber {

    public struct Territory: Identifiable, Hashable {

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

    /// Available territories.
    public var territories: [Territory]

    /// Currently selected territory.
    public var territory: Territory?

    /// Local phone number.
    public var number: String

    public init(territories: [Territory]? = nil, territory: Territory? = nil, number: String) {
        self.territories = territories ?? POPhoneNumber.Territory.all
        self.territory = territory
        self.number = number
    }
}

extension POPhoneNumber.Territory {

    static var all: [POPhoneNumber.Territory] {
        // todo(andrii-vysotskyi): update supported territories
        [
            Self(id: "UA", displayName: "Ukraine", code: "380"),
            Self(id: "PL", displayName: "Poland", code: "48"),
            Self(id: "CA", displayName: "Canada", code: "1"),
            Self(id: "US", displayName: "United States", code: "1")
        ]
    }
}
