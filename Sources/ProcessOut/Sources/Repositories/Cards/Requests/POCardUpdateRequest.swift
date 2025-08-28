//
//  POCardUpdateRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.03.2023.
//

/// Updated card details.
public struct POCardUpdateRequest: Codable, Sendable {

    /// Card id.
    public let cardId: String

    /// New cvc.
    /// Pass `nil` to keep existing value.
    public let cvc: String?

    /// Preferred scheme defined by the Customer. This gets priority when processing the Transaction.
    /// Pass `nil` to keep existing value.
    @POTypedRepresentation<String?, POCardScheme>
    public private(set) var preferredScheme: String?

    /// Customer's locale identifier override.
    @POExcludedEncodable
    public private(set) var localeIdentifier: String?

    /// Creates request instance.
    public init(cardId: String, cvc: String? = nil, preferredScheme: String? = nil, localeIdentifier: String? = nil) {
        self.cardId = cardId
        self.cvc = cvc
        self._preferredScheme = .init(wrappedValue: preferredScheme)
        self._localeIdentifier = .init(wrappedValue: localeIdentifier)
    }
}
