//
//  POCardUpdateRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.03.2023.
//

public struct POCardUpdateRequest: Encodable {

    /// Card id.
    @POImmutableExcludedCodable
    public var cardId: String

    /// New cvc.
    public let cvc: String

    /// Creates request instance.
    public init(cardId: String, cvc: String) {
        self._cardId = .init(value: cardId)
        self.cvc = cvc
    }
}
