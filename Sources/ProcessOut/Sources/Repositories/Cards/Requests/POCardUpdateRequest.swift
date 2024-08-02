//
//  POCardUpdateRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.03.2023.
//

/// Updated card details.
public struct POCardUpdateRequest: Encodable, Sendable { // sourcery: AutoCodingKeys

    /// Card id.
    public let cardId: String // sourcery:coding: skip

    /// New cvc.
    /// Pass `nil` to keep existing value.
    public let cvc: String?

    /// Preferred scheme defined by the Customer. This gets priority when processing the Transaction.
    /// Pass `nil` to keep existing value.
    public let preferredScheme: POCardScheme?

    /// Creates request instance.
    public init(cardId: String, cvc: String? = nil, preferredScheme: POCardScheme? = nil) {
        self.cardId = cardId
        self.cvc = cvc
        self.preferredScheme = preferredScheme
    }
}
