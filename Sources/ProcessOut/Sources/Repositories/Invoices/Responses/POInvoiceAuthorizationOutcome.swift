//
//  POInvoiceAuthorizationOutcome.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2026.
//

/// Authorization outcome based on the request intent and current transaction status.
public struct POInvoiceAuthorizationOutcome: RawRepresentable, Sendable {

    /// Raw status.
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension POInvoiceAuthorizationOutcome: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.lowercased())
    }

    public static func == (lhs: POInvoiceAuthorizationOutcome, rhs: POInvoiceAuthorizationOutcome) -> Bool {
        lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }
}

extension POInvoiceAuthorizationOutcome: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

extension POInvoiceAuthorizationOutcome {

    /// Successful operation.
    public static let success = POInvoiceAuthorizationOutcome(rawValue: "success")

    /// Operation is pending.
    public static let pending = POInvoiceAuthorizationOutcome(rawValue: "pending")
}
