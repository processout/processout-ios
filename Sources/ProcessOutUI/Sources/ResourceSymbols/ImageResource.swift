//
//  ImageResource.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 31.07.2024.
//

@_spi(PO) import ProcessOutCoreUI

extension POImageResource {

    init(name: String) {
        self.init(name: name, bundle: BundleLocator.bundle)
    }
}

extension POImageResource {

    /// The "Schemes" asset catalog resource namespace.
    enum Schemes {

        /// The "Schemes/Amex" asset catalog image resource.
        static let amex = POImageResource(name: "Schemes/Amex")

        /// The "Schemes/CarteBancaire" asset catalog image resource.
        static let carteBancaire = POImageResource(name: "Schemes/CarteBancaire")

        /// The "Schemes/Dinacard" asset catalog image resource.
        static let dinacard = POImageResource(name: "Schemes/Dinacard")

        /// The "Schemes/Diners" asset catalog image resource.
        static let diners = POImageResource(name: "Schemes/Diners")

        /// The "Schemes/Discover" asset catalog image resource.
        static let discover = POImageResource(name: "Schemes/Discover")

        /// The "Schemes/Elo" asset catalog image resource.
        static let elo = POImageResource(name: "Schemes/Elo")

        /// The "Schemes/Giropay" asset catalog image resource.
        static let giropay = POImageResource(name: "Schemes/Giropay")

        /// The "Schemes/JCB" asset catalog image resource.
        static let JCB = POImageResource(name: "Schemes/JCB")

        /// The "Schemes/Mada" asset catalog image resource.
        static let mada = POImageResource(name: "Schemes/Mada")

        /// The "Schemes/Maestro" asset catalog image resource.
        static let maestro = POImageResource(name: "Schemes/Maestro")

        /// The "Schemes/Mastercard" asset catalog image resource.
        static let mastercard = POImageResource(name: "Schemes/Mastercard")

        /// The "Schemes/Rupay" asset catalog image resource.
        static let rupay = POImageResource(name: "Schemes/Rupay")

        /// The "Schemes/Sodexo" asset catalog image resource.
        static let sodexo = POImageResource(name: "Schemes/Sodexo")

        /// The "Schemes/UnionPay" asset catalog image resource.
        static let unionPay = POImageResource(name: "Schemes/UnionPay")

        /// The "Schemes/Verve" asset catalog image resource.
        static let verve = POImageResource(name: "Schemes/Verve")

        /// The "Schemes/Visa" asset catalog image resource.
        static let visa = POImageResource(name: "Schemes/Visa")

        /// The "Schemes/Vpay" asset catalog image resource.
        static let vpay = POImageResource(name: "Schemes/Vpay")
    }

    /// The "Card" asset catalog resource namespace.
    enum Card {

        /// The "Card/Back" asset catalog image resource.
        static let back = POImageResource(name: "Card/Back")
    }

    /// The "Lightning" asset catalog image resource.
    static let lightning = POImageResource(name: "Lightning")

    /// The "LightningSlash" asset catalog image resource.
    static let lightningSlash = POImageResource(name: "LightningSlash")

    /// The "Success" asset catalog image resource.
    static let success = POImageResource(name: "Success")
}
