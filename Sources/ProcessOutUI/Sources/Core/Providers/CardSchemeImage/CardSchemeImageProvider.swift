//
//  CardSchemeImageProvider.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 07.11.2023.
//

import SwiftUI
import ProcessOut
@_spi(PO) import ProcessOutCoreUI

final class CardSchemeImageProvider {

    static let shared = CardSchemeImageProvider()

    func image(for scheme: POCardScheme) -> Image? {
        guard let resource = resources[scheme] else {
            return nil
        }
        return Image(resource)
    }

    // MARK: - Private Properties

    private let resources: [POCardScheme: POImageResource] = [
        .amex: .Schemes.amex,
        .carteBancaire: .Schemes.carteBancaire,
        .dinaCard: .Schemes.dinacard,
        .dinersClub: .Schemes.diners,
        .dinersClubCarteBlanche: .Schemes.diners,
        .dinersClubInternational: .Schemes.diners,
        .dinersClubUnitedStatesAndCanada: .Schemes.diners,
        .discover: .Schemes.discover,
        .elo: .Schemes.elo,
        .giropay: .Schemes.giropay,
        .jcb: .Schemes.JCB,
        .mada: .Schemes.mada,
        .maestro: .Schemes.maestro,
        .mastercard: .Schemes.mastercard,
        .rupay: .Schemes.rupay,
        .sodexo: .Schemes.sodexo,
        .unionPay: .Schemes.unionPay,
        .verve: .Schemes.verve,
        .visa: .Schemes.visa,
        .vPay: .Schemes.vpay
    ]

    // MARK: - Private Methods

    private init() { }
}
