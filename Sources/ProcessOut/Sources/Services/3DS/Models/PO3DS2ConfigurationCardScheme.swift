//
//  PO3DS2ConfigurationCardScheme.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.03.2023.
//

// sourcery: AutoStringRepresentable
/// Available card schemes.
public enum PO3DS2ConfigurationCardScheme: Decodable, Hashable {

    /// Card scheme.
    case visa, mastercard, europay, jcb, diners, discover, unionpay

    /// Carte Bancaire (CB).
    case carteBancaire // sourcery: rawValue = "carte bancaire"

    /// American Express.
    case americanExpress // sourcery: rawValue = "american express"

    /// Used for schemes unknown to sdk.
    case unknown(String)
}
