//
//  POCardUpdateInformation.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 06.11.2023.
//

/// Short card information necessary for CVC update.
public struct POCardUpdateInformation {

    /// Masked card number displayed to user as is if set.
    public let maskedNumber: String?

    /// Card issuer identification number. Corresponds to the first 6 or 8 digits of the main card number.
    ///
    /// When this property is nil implementation will attempt to extract IIN from ``maskedNumber``.
    /// You may want to set this property explicity if you know that masked number's iin may be unavailable.
    public let iin: String?

    /// Scheme of the card.
    public let scheme: String?

    /// Preferred scheme previously selected by customer if any.
    public let preferredScheme: String?

    public init(
        maskedNumber: String? = nil, iin: String? = nil, scheme: String? = nil, preferredScheme: String? = nil
    ) {
        self.maskedNumber = maskedNumber
        self.iin = iin
        self.scheme = scheme
        self.preferredScheme = preferredScheme
    }
}
