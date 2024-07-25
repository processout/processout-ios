//
//  PO3DS2ConfigurationCardScheme.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.03.2023.
//

// todo(andrii-vysotskyi): remove when updating to 5.0.0

/// Available card schemes.
public enum PO3DS2ConfigurationCardScheme: RawRepresentable, Decodable, Hashable {

    /// Known card schemes.
    case visa, mastercard, europay, carteBancaire, jcb, diners, discover, unionpay, americanExpress

    /// Used for schemes unknown to sdk.
    case unknown(String)

    public init(rawValue: String) {
        self = Self.knownSchemes[rawValue] ?? .unknown(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .visa:
            return Constants.visa
        case .mastercard:
            return Constants.mastercard
        case .europay:
            return Constants.europay
        case .carteBancaire:
            return Constants.carteBancaire
        case .jcb:
            return Constants.jcb
        case .diners:
            return Constants.diners
        case .discover:
            return Constants.discover
        case .unionpay:
            return Constants.unionpay
        case .americanExpress:
            return Constants.americanExpress
        case .unknown(let rawValue):
            return rawValue
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let visa = "visa"
        static let mastercard = "mastercard"
        static let europay = "europay"
        static let carteBancaire = "carte bancaire"
        static let jcb = "jcb"
        static let diners = "diners"
        static let discover = "discover"
        static let unionpay = "unionpay"
        static let americanExpress = "american express"
    }

    // MARK: - Private Properties

    private static let knownSchemes: [String: Self] = [
        Constants.visa: .visa,
        Constants.mastercard: .mastercard,
        Constants.europay: .europay,
        Constants.carteBancaire: .carteBancaire,
        Constants.jcb: .jcb,
        Constants.diners: .diners,
        Constants.discover: .discover,
        Constants.unionpay: .unionpay,
        Constants.americanExpress: .americanExpress
    ]
}
