//
//  POCodablePassKitPaymentNetworks.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.03.2025.
//

import PassKit

/// Property wrapper allowing to decode `PKPaymentNetwork`s.
@propertyWrapper
public struct POCodablePassKitPaymentNetworks: Codable, Sendable {

    public let wrappedValue: Set<PKPaymentNetwork>

    // MARK: - Decodable

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        schemes = try container.decode(Set<CodablePassKitPaymentNetwork>.self)
        wrappedValue = Set(schemes.compactMap(\.wrappedValue))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(schemes)
    }

    // MARK: - Private Properties

    private let schemes: Set<CodablePassKitPaymentNetwork>
}

private struct CodablePassKitPaymentNetwork: Codable, Sendable, Hashable {

    let wrappedValue: PKPaymentNetwork?

    // MARK: - Decodable

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let scheme = try container.decode(POCardScheme.self)
        if let network = Self.networks[scheme] {
            wrappedValue = network
        } else {
            wrappedValue = nil
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        if let network = wrappedValue, let scheme = Self.schemes[network] {
            try container.encode(scheme)
        } else {
            try container.encodeNil()
        }
    }

    // MARK: - Private Properties

    private static let networks: [POCardScheme: PKPaymentNetwork] = {
        var schemes: [POCardScheme: PKPaymentNetwork] = [
            .amex: .amex,
            .carteBancaire: .cartesBancaires,
            .unionPay: .chinaUnionPay,
            .discover: .discover,
            .electron: .electron,
            .elo: .elo,
            .idCredit: .idCredit,
            .interac: .interac,
            .jcb: .JCB,
            .mada: .mada,
            .maestro: .maestro,
            .mastercard: .masterCard,
            .privateLabel: .privateLabel,
            .quicPay: .quicPay,
            .suica: .suica,
            .visa: .visa,
            .vPay: .vPay,
            "eftpos": .eftpos
        ]
        if #available(iOS 17.4, *) {
            schemes[.meeza] = .meeza
        }
        if #available(iOS 17.0, *) {
            schemes[.pagoBancomat] = .pagoBancomat
            schemes[.tmoney] = .tmoney
        }
        if #available(iOS 16.4, *) {
            schemes[.postFinance] = .postFinance
        }
        if #available(iOS 16.0, *) {
            schemes[.bancontact] = .bancontact
        }
        if #available(iOS 15.1, *) {
            schemes[.dankort] = .dankort
        }
        if #available(iOS 15.0, *) {
            schemes[.nanaco] = .nanaco
            schemes[.waon] = .waon
        }
        if #available(iOS 14.5, *) {
            schemes[.mir] = .mir
        }
        if #available(iOS 14, *) {
            schemes[.girocard] = .girocard
            schemes["barcode"] = .barcode
        }
        return schemes
    }()

    private static let schemes: [PKPaymentNetwork: POCardScheme] = {
        var schemes: [PKPaymentNetwork: POCardScheme] = [:]
        schemes.reserveCapacity(Self.networks.count)
        for (scheme, network) in Self.networks {
            schemes[network] = scheme
        }
        return schemes
    }()
}
