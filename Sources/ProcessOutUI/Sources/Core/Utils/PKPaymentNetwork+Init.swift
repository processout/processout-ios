//
//  PKPaymentNetwork+Init.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 14.05.2024.
//

import PassKit
import ProcessOut

@available(iOS 14.0, *)
extension PKPaymentNetwork {

    init?(poScheme: POCardScheme) {
        if let scheme = Self.schemes[poScheme] {
            self = scheme
        } else {
            return nil
        }
    }

    // MARK: - Private Properties

    private static let schemes: [POCardScheme: PKPaymentNetwork] = {
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
            .girocard: .girocard,
            .unknown("eftpos"): .eftpos,
            .unknown("barcode"): .barcode
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
        return schemes
    }()
}
