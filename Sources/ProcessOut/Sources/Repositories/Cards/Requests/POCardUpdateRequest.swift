//
//  POCardUpdateRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.03.2023.
//

/// Updated card details.
public struct POCardUpdateRequest: Encodable {

    /// Card id.
    @POImmutableExcludedCodable
    public var cardId: String

    /// New cvc.
    /// Pass `nil` to keep existing value.
    public let cvc: String?

    /// Preferred scheme defined by the Customer. This gets priority when processing the Transaction.
    /// Pass `nil` to keep existing value.
    public let preferredScheme: String?

    /// Creates request instance.
    public init(cardId: String, cvc: String? = nil, preferredScheme: String? = nil) {
        self._cardId = .init(value: cardId)
        self.cvc = cvc
        self.preferredScheme = preferredScheme
    }
}
