//
//  POCardScheme.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.02.2024.
//

/// Possible card schemes and co-schemes.
public enum POCardScheme: Decodable, Hashable { // sourcery: AutoStringRepresentable

    /// Visa is the largest global card network in the world by transaction value, ubiquitous worldwide.
    case visa

    /// Cartes Bancaires is France's local card scheme and the most widely used payment method in the region.
    case carteBancaire // sourcery: rawValue = "carte bancaire"

    /// Mastercard is a market leading card scheme worldwide.
    case mastercard

    /// American Express is a key credit card around the world.
    case amex // sourcery: rawValue = "american express"

    /// UnionPay is the world’s biggest card network with more than 7 billion cards issued.
    case unionPay // sourcery: rawValue = "china union pay"

    /// Diners charge card.
    case dinersClub // sourcery: rawValue = "diners club"

    /// Diners charge card.
    case dinersClubCarteBlanche // sourcery: rawValue = "diners club carte blanche"

    /// Diners charge card.
    case dinersClubInternational // sourcery: rawValue = "diners club international"

    /// Diners charge card.
    case dinersClubUnitedStatesAndCanada // sourcery: rawValue = "diners club united states & canada"

    /// Discover is a credit card brand issued primarily in the United States.
    case discover

    /// JCB is a major card issuer and acquirer from Japan.
    case jcb

    /// Maestro is a brand of debit cards and prepaid cards owned by Mastercard.
    case maestro

    /// The Dankort is the national debit card of Denmark.
    case dankort

    /// Verve is Africa's most successful card brand.
    case verve

    /// RuPay is an Indian multinational financial services and payment service system.
    case rupay

    /// Domestic debit and credit card brand of Brazil.
    case cielo, elo, hipercard, ourocard, aura, comprocard

    /// Cabal is a local credit and debit card payment method based in Argentina.
    case cabal

    /// The New York Currency Exchange (NYCE) is an interbank network connecting the ATMs of various
    /// financial institutions in the United States and Canada.
    case nyce

    /// Mastercard Cirrus is a worldwide interbank network that provides cash to Mastercard cardholders.
    case cirrus

    /// TROY (acronym of Türkiye’nin Ödeme Yöntemi) is a Turkish card scheme
    case troy

    /// Pay is a Single Euro Payments Area (SEPA) debit card for use in Europe, issued by Visa Europe.
    /// It uses the EMV chip and PIN system and may be co-branded with various national debit card schemes
    /// such as the German Girocard.
    case vPay // sourcery: rawValue = "vpay"

    /// Carnet is a leading brand of Mexican acceptance, with more than 50 years of experience.
    case carnet

    /// GE Capital is the financial services division of General Electric.
    case geCapital // sourcery: rawValue = "ge capital"

    /// UK Credit Cards issued by NewDay.
    case newday

    /// Sodexo is a company that offers prepaid meal cards and other prepaid services.
    case sodexo

    /// South Korean domestic card brand with international acceptance.
    case globalBc // sourcery: rawValue = "global bc"

    /// DinaCard is a national payment card of the Republic of Serbia.
    case dinaCard // sourcery: rawValue = "dinacard"

    /// Mada is the national payment scheme of Saudi Arabia
    case mada

    /// Bancontact is the most popular online payment method in Belgium.
    case bancontact

    /// A private label credit card is a type of credit card that is branded for a specific retailer or brand.
    case privateLabel // sourcery: rawValue = "private label"

    /// A private label credit card that is branded for Atos.
    case atosPrivateLabel // sourcery: rawValue = "atos private label"

    /// Unknown card scheme.
    case unknown(String)
}
