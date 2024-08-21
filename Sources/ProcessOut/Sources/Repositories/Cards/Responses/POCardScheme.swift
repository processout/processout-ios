//
//  POCardScheme.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.02.2024.
//

/// Possible card schemes and co-schemes.
public struct POCardScheme: Hashable, RawRepresentable, ExpressibleByStringLiteral, Sendable {

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    @_disfavoredOverload
    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public let rawValue: String
}

// Defined values are a subset of values defined in https://github.com/processout/norms/blob/master/card_schemes.go
extension POCardScheme {

    /// Visa is the largest global card network in the world by transaction value, ubiquitous worldwide.
    public static let visa: POCardScheme = "visa"

    /// Cartes Bancaires is France's local card scheme and the most widely used payment method in the region.
    public static let carteBancaire: POCardScheme = "carte bancaire"

    /// Mastercard is a market leading card scheme worldwide.
    public static let mastercard: POCardScheme = "mastercard"

    /// American Express is a key credit card around the world.
    public static let amex: POCardScheme = "american express"

    /// UnionPay is the world’s biggest card network with more than 7 billion cards issued.
    public static let unionPay: POCardScheme = "china union pay"

    /// Diners charge card.
    public static let dinersClub: POCardScheme = "diners club"

    /// Diners charge card.
    public static let dinersClubCarteBlanche: POCardScheme = "diners club carte blanche"

    /// Diners charge card.
    public static let dinersClubInternational: POCardScheme = "diners club international"

    /// Diners charge card.
    public static let dinersClubUnitedStatesAndCanada: POCardScheme = "diners club united states & canada"

    /// Discover is a credit card brand issued primarily in the United States.
    public static let discover: POCardScheme = "discover"

    /// JCB is a major card issuer and acquirer from Japan.
    public static let jcb: POCardScheme = "jcb"

    /// Maestro is a brand of debit cards and prepaid cards owned by Mastercard.
    public static let maestro: POCardScheme = "maestro"

    /// The Dankort is the national debit card of Denmark.
    public static let dankort: POCardScheme = "dankort"

    /// A Mir payment card.
    public static let mir: POCardScheme = "nspk mir"

    /// Verve is Africa's most successful card brand.
    public static let verve: POCardScheme = "verve"

    /// RuPay is an Indian multinational financial services and payment service system.
    public static let rupay: POCardScheme = "rupay"

    /// Domestic debit and credit card brand of Brazil.
    public static let cielo: POCardScheme = "cielo"

    /// Domestic debit and credit card brand of Brazil.
    public static let elo: POCardScheme = "elo"

    /// Domestic debit and credit card brand of Brazil.
    public static let hipercard: POCardScheme = "hipercard"

    /// Cabal is a local credit and debit card payment method based in Argentina.
    public static let cabal: POCardScheme = "cabal"

    /// The New York Currency Exchange (NYCE) is an interbank network connecting the ATMs of various
    /// financial institutions in the United States and Canada.
    public static let nyce: POCardScheme = "nyce"

    /// TROY (acronym of Türkiye’nin Ödeme Yöntemi) is a Turkish card scheme
    public static let troy: POCardScheme = "troy"

    /// Pay is a Single Euro Payments Area (SEPA) debit card for use in Europe, issued by Visa Europe.
    /// It uses the EMV chip and PIN system and may be co-branded with various national debit card schemes
    /// such as the German Girocard.
    public static let vPay: POCardScheme = "vpay"

    /// A private label credit card is a type of credit card that is branded for a specific retailer or brand.
    public static let privateLabel: POCardScheme = "private label"

    /// Mastercard Cirrus is a worldwide interbank network that provides cash to Mastercard cardholders.
    public static let cirrus: POCardScheme = "cirrus"

    /// Domestic debit and credit card brand of Brazil.
    public static let ourocard: POCardScheme = "ourocard"

    /// Carnet is a leading brand of Mexican acceptance, with more than 50 years of experience.
    public static let carnet: POCardScheme = "carnet"

    /// A private label credit card that is branded for Atos.
    public static let atosPrivateLabel: POCardScheme = "atos private label"

    /// Domestic debit and credit card brand of Brazil.
    public static let aura: POCardScheme = "aura"

    /// GE Capital is the financial services division of General Electric.
    public static let geCapital: POCardScheme = "ge capital"

    /// UK Credit Cards issued by NewDay.
    public static let newday: POCardScheme = "newday"

    /// Sodexo is a company that offers prepaid meal cards and other prepaid services.
    public static let sodexo: POCardScheme = "sodexo"

    /// South Korean domestic card brand with international acceptance.
    public static let globalBc: POCardScheme = "global bc"

    /// DinaCard is a national payment card of the Republic of Serbia.
    public static let dinaCard: POCardScheme = "dinacard"

    /// Domestic debit and credit card brand of Brazil.
    public static let comprocard: POCardScheme = "comprocard"

    /// Mada is the national payment scheme of Saudi Arabia
    public static let mada: POCardScheme = "mada"

    /// Bancontact is the most popular online payment method in Belgium.
    public static let bancontact: POCardScheme = "bancontact"

    /// A Girocard payment method.
    public static let girocard: POCardScheme = "girocard"

    /// The Interac payment method.
    public static let interac: POCardScheme = "interac"

    /// A Meeza payment card.
    public static let meeza: POCardScheme = "meeza"

    /// A Nanaco payment card.
    public static let nanaco: POCardScheme = "nanaco"

    /// A Bancomat payment card.
    public static let pagoBancomat: POCardScheme = "pagobancomat"

    /// A PostFinance AG payment card.
    public static let postFinance: POCardScheme = "postfinance"

    /// A QUICPay payment card.
    public static let quicPay: POCardScheme = "quicpay"

    /// A Suica payment card.
    public static let suica: POCardScheme = "suica"

    /// The TMoney card.
    public static let tmoney: POCardScheme = "tmoney"

    /// A WAON payment card.
    public static let waon: POCardScheme = "waon"
}

extension POCardScheme {

    /// Giropay is an Internet payment System in Germany
    public static let giropay: POCardScheme = "giropay"

    /// An Electron debit card.
    public static let electron: POCardScheme = "electron"

    /// An iD payment card.
    public static let idCredit: POCardScheme = "idCredit"
}

extension POCardScheme: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}
