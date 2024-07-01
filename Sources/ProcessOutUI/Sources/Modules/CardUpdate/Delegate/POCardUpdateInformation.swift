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
    /// You may want to set this property explicitly if you know that masked number's IIN may be unavailable.
    ///
    /// - NOTE: When this property is set, `scheme` and `coScheme` could be `nil`.
    public let iin: String?

    /// Scheme of the card.
    @POTypedRepresentation<String?, POCardScheme>
    public private(set) var scheme: String?

    /// Co-scheme of the card, such as Carte Bancaire.
    @POTypedRepresentation<String?, POCardScheme>
    public private(set) var coScheme: String?

    /// Preferred scheme previously selected by customer if any.
    @POTypedRepresentation<String?, POCardScheme>
    public private(set) var preferredScheme: String?

    public init(
        maskedNumber: String? = nil,
        iin: String? = nil,
        scheme: String? = nil,
        coScheme: String? = nil,
        preferredScheme: String? = nil
    ) {
        self.maskedNumber = maskedNumber
        self.iin = iin
        self.scheme = scheme
        self.coScheme = coScheme
        self.preferredScheme = preferredScheme
    }
}
