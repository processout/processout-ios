//
//  PKPaymentNetwork+Init.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 14.05.2024.
//

import PassKit

@available(iOS 14.0, *)
extension PKPaymentNetwork {

    init(poScheme: String) {
        self = Self.schemes[poScheme] ?? .init(poScheme)
    }

    // MARK: - Private Properties

    private static let schemes: [String: PKPaymentNetwork] = {
        // todo(andrii-vysotskyi): decide if pagoBancomat, postFinance, tmoney and meeza should be supported
        var schemes: [String: PKPaymentNetwork] = [
            "american express": .amex,
            "cartesBancaires": .cartesBancaires,
            "chinaUnionPay": .chinaUnionPay,
            "discover": .discover,
            "eftpos": .eftpos,
            "electron": .electron,
            "elo": .elo,
            "idCredit": .idCredit,
            "interac": .interac,
            "jcb": .JCB,
            "mada": .mada,
            "maestro": .maestro,
            "masterCard": .masterCard,
            "privateLabel": .privateLabel,
            "quicPay": .quicPay,
            "suica": .suica,
            "visa": .visa,
            "vPay": .vPay,
            "barcode": .barcode,
            "girocard": .girocard
        ]
        if #available(iOS 16.0, *) {
            schemes["bancontact"] = .bancontact
        }
        if #available(iOS 15.1, *) {
            schemes["dankort"] = .dankort
        }
        if #available(iOS 15.0, *) {
            schemes["nanaco"] = .nanaco
            schemes["waon"] = .waon
        }
        if #available(iOS 14.5, *) {
            schemes["mir"] = .mir
        }
        return schemes
    }()
}
