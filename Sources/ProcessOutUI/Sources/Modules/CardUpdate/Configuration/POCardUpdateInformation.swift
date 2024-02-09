//
//  POCardUpdateInformation.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 06.11.2023.
//

import ProcessOut

/// Short card information necessary for CVC update.
public struct POCardUpdateInformation {

    /// Masked card number displayed to user as is if set.
    public let maskedNumber: String?

    /// Card issuer identification number. Corresponds to the first 6 or 8 digits of the main card number.
    ///
    /// When this property is nil implementation will attempt to extract IIN from ``maskedNumber``.
    /// You may want to set this property explicity if you know that masked number's iin may be unavailable.
    ///
    /// - NOTE: When this property is set, `scheme` and `coScheme` could be `nil`.
    public let iin: String?

    /// Scheme of the card.
    public let scheme: POCardScheme?

    /// Co-scheme of the card, such as Carte Bancaire.
    public let coScheme: POCardScheme?

    /// Preferred scheme previously selected by customer if any.
    public let preferredScheme: POCardScheme?

    public init(
        maskedNumber: String? = nil,
        iin: String? = nil,
        scheme: POCardScheme? = nil,
        coScheme: POCardScheme? = nil,
        preferredScheme: POCardScheme? = nil
    ) {
        self.maskedNumber = maskedNumber
        self.iin = iin
        self.scheme = scheme
        self.coScheme = coScheme
        self.preferredScheme = preferredScheme
    }
}
