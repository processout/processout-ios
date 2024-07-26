//
//  POCardCvcCheck.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.02.2024.
//

/// Current card CVC verification status.
public struct POCardCvcCheck: Hashable, RawRepresentable, ExpressibleByStringLiteral, Sendable {

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    @_disfavoredOverload
    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public let rawValue: String
}

extension POCardCvcCheck {

    /// The CVC was sent and was correct.
    public static let passed: POCardCvcCheck = "passed"

    /// The CVC was sent but was incorrect.
    public static let failed: POCardCvcCheck = "failed"

    /// The CVC was sent but wasn't checked by the issuing bank.
    public static let unchecked: POCardCvcCheck = "unchecked"

    /// The CVC wasn't sent as it either wasn't specified by the user, or the
    /// transaction is recurring and the CVC was previously deleted.
    public static let unavailable: POCardCvcCheck = "unavailable"

    /// The CVC wasn't available, but the card/issuer required the CVC to be provided to process the transaction.
    public static let `required`: POCardCvcCheck = "required"
}

extension POCardCvcCheck: Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
}
