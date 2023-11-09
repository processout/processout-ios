//
//  CardSchemeImageProvider.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 07.11.2023.
//

import SwiftUI

final class CardSchemeImageProvider {

    static let shared = CardSchemeImageProvider()

    func image(for scheme: String) -> Image? {
        let normalizedScheme = scheme.lowercased()
        guard let resource = resources[normalizedScheme] else {
            return nil
        }
        return Image(resource)
    }

    // MARK: - Private Properties

    private let resources: [String: ImageResource] = [
        "american express": .Schemes.amex,
        "carte bancaire": .Schemes.carteBancaire,
        "dinacard": .Schemes.dinacard,
        "diners club": .Schemes.diners,
        "diners club carte blanche": .Schemes.diners,
        "diners club international": .Schemes.diners,
        "diners club united states & canada": .Schemes.diners,
        "discover": .Schemes.discover,
        "elo": .Schemes.elo,
        "jcb": .Schemes.JCB,
        "mada": .Schemes.mada,
        "maestro": .Schemes.maestro,
        "mastercard": .Schemes.mastercard,
        "rupay": .Schemes.rupay,
        "sodexo": .Schemes.sodexo,
        "china union pay": .Schemes.unionPay,
        "verve": .Schemes.verve,
        "visa": .Schemes.visa,
        "vpay": .Schemes.vpay
    ]

    // MARK: - Private Methods

    private init() { }
}
